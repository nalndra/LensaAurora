"""
================================================================
  DETEKSI MATA REAL-TIME (PRO VERSION) — ASD Diagnostic Suite
  LensaAurora / NeuroAssist
  Metrics: Fixations, Visual Preference, AOI, Saccades, 
           Gaze Following, Pupil Dilation
================================================================
"""

import cv2
import mediapipe as mp
import numpy as np
import time
import os
from collections import deque

# Suppress TF/protobuf warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3'
os.environ['GLOG_minloglevel'] = '3'

# ── Inisialisasi MediaPipe ───────────────────────────────────
mp_face_mesh  = mp.solutions.face_mesh
mp_drawing    = mp.solutions.drawing_utils

# Landmark index
LEFT_EYE  = [33, 160, 158, 133, 153, 144]
RIGHT_EYE = [362, 385, 387, 263, 373, 380]
LEFT_IRIS = [474, 475, 476, 477]
RIGHT_IRIS = [469, 470, 471, 472]
MOUTH      = [0, 13, 14, 17, 37, 39, 40, 61, 146, 91, 181, 84, 17, 314, 405, 321, 375, 291, 308, 324, 318]

# ── Metrics Engine ───────────────────────────────────────────
class ASDMetricsEngine:
    def __init__(self, buffer_size=60):
        self.gaze_history = deque(maxlen=buffer_size)
        self.fixation_start = time.time()
        self.last_gaze_pos = None
        
        # Core Metrics
        self.fixation_durations = []
        self.fixation_locations = []
        self.saccade_velocities = []
        self.saccade_accuracies = [] # Distance from target vs final gaze
        self.aoi_counts = {"EYES": 0, "MOUTH": 0, "SOCIAL": 0, "NON_SOCIAL": 0}
        self.pupil_sizes = deque(maxlen=150)
        self.gaze_following_events = [] # (stimulus_pos, gaze_pos, success_bool)
        
        self.total_frames = 0
        self.start_time = time.time()
        
        # New: Fixation Stability & Latency
        self.current_fixation_points = []
        self.gaze_following_latencies = []
        
        # Thresholds (Adaptive)
        self.SACCADE_VEL_THRESHOLD = 12.0 # Pixels per frame
        self.FIXATION_MIN_TIME = 0.2     # Detik (Clinical standard)
        self.STIMULUS_POS = None         # Simulated or real stimulus

    def update(self, iris_pos, face_geometry, w, h, stimulus_pos=None):
        self.total_frames += 1
        curr_time = time.time()
        self.STIMULUS_POS = stimulus_pos
        
        # 1. Saccade & Fixation Logic
        if self.last_gaze_pos is not None:
            dist = np.linalg.norm(np.array(iris_pos) - np.array(self.last_gaze_pos))
            
            if dist > self.SACCADE_VEL_THRESHOLD:
                # Saccade occurring
                self.saccade_velocities.append(dist)
                
                # End of a fixation?
                fix_dur = curr_time - self.fixation_start
                if fix_dur > self.FIXATION_MIN_TIME and self.current_fixation_points:
                    self.fixation_durations.append(fix_dur)
                    # Store mean location of the fixation
                    avg_loc = np.mean(self.current_fixation_points, axis=0)
                    self.fixation_locations.append(tuple(avg_loc.astype(int)))
                    
                    # Saccade Accuracy: How close was the previous fixation to the stimulus?
                    if self.STIMULUS_POS:
                        acc = np.linalg.norm(np.array(avg_loc) - np.array(self.STIMULUS_POS))
                        self.saccade_accuracies.append(acc)
                
                self.fixation_start = curr_time
                self.current_fixation_points = []
            else:
                # Stable gaze (Fixation in progress)
                self.current_fixation_points.append(iris_pos)

        # 2. Visual Preference & AOI (Area of Interest)
        eye_center = face_geometry['eye_center']
        mouth_center = face_geometry['mouth_center']
        face_center = face_geometry['face_center']
        face_radius = face_geometry['face_radius']
        
        dist_to_eyes = np.linalg.norm(np.array(iris_pos) - np.array(eye_center))
        dist_to_mouth = np.linalg.norm(np.array(iris_pos) - np.array(mouth_center))
        dist_to_face = np.linalg.norm(np.array(iris_pos) - np.array(face_center))
        
        # Hitung Atensi Sosial vs Non-Sosial
        if dist_to_face < face_radius:
            self.aoi_counts["SOCIAL"] += 1
            if dist_to_eyes < face_radius * 0.3:
                self.aoi_counts["EYES"] += 1
            elif dist_to_mouth < face_radius * 0.3:
                self.aoi_counts["MOUTH"] += 1
        else:
            self.aoi_counts["NON_SOCIAL"] += 1
            
        # 3. Gaze Following Logic (Joint Attention)
        if stimulus_pos is not None:
            dist_to_stim = np.linalg.norm(np.array(iris_pos) - np.array(stimulus_pos))
            success = dist_to_stim < (face_radius * 0.8) # Adaptive threshold
            self.gaze_following_events.append(success)
            
            if success:
                latency = curr_time - self.fixation_start
                self.gaze_following_latencies.append(latency)

        # 4. Pupil Dilation (Relative to baseline)
        pupil_ratio = face_geometry['iris_diameter'] / max(face_geometry['eye_width'], 1)
        self.pupil_sizes.append(pupil_ratio)
        
        self.last_gaze_pos = iris_pos
        self.gaze_history.append(iris_pos)

    def get_report(self):
        avg_fix = np.mean(self.fixation_durations) if self.fixation_durations else 0
        avg_sac_vel = np.mean(self.saccade_velocities) if self.saccade_velocities else 0
        avg_sac_acc = np.mean(self.saccade_accuracies) if self.saccade_accuracies else 0
        
        total_aoi = self.aoi_counts["SOCIAL"] + self.aoi_counts["NON_SOCIAL"]
        social_pref = (self.aoi_counts["SOCIAL"] / max(total_aoi, 1)) * 100
        
        gaze_follow_rate = (sum(self.gaze_following_events) / max(len(self.gaze_following_events), 1)) * 100
        avg_latency = np.mean(self.gaze_following_latencies) if self.gaze_following_latencies else 0
        
        # Pupil reactivity (Emotional response indicator)
        pupil_var = np.std(self.pupil_sizes) if len(self.pupil_sizes) > 10 else 0
        
        return {
            "avg_fixation": avg_fix,
            "avg_saccade_vel": avg_sac_vel,
            "saccade_accuracy": avg_sac_acc,
            "social_preference": social_pref,
            "aoi_eyes_pct": (self.aoi_counts["EYES"] / max(self.aoi_counts["SOCIAL"], 1)) * 100,
            "aoi_mouth_pct": (self.aoi_counts["MOUTH"] / max(self.aoi_counts["SOCIAL"], 1)) * 100,
            "gaze_following": gaze_follow_rate,
            "gaze_latency": avg_latency,
            "pupil_dynamic": pupil_var
        }

# ── Utility Functions ────────────────────────────────────────
def get_point(lm, idx, w, h):
    return (int(lm[idx].x * w), int(lm[idx].y * h))

def get_face_geometry(lm, w, h):
    # Mata (Social AOI)
    l_eye = get_point(lm, 33, w, h)
    r_eye = get_point(lm, 263, w, h)
    eye_center = ((l_eye[0] + r_eye[0]) // 2, (l_eye[1] + r_eye[1]) // 2)
    eye_width = np.linalg.norm(np.array(l_eye) - np.array(r_eye))
    
    # Mulut (Non-social/Detail AOI)
    m_top = get_point(lm, 13, w, h)
    m_bot = get_point(lm, 14, w, h)
    mouth_center = ((m_top[0] + m_bot[0]) // 2, (m_top[1] + m_bot[1]) // 2)
    
    # Face Boundary (Social vs Non-Social proxy)
    f_top = get_point(lm, 10, w, h)
    f_bot = get_point(lm, 152, w, h)
    face_center = ((f_top[0] + f_bot[0]) // 2, (f_top[1] + f_bot[1]) // 2)
    face_radius = np.linalg.norm(np.array(f_top) - np.array(f_bot)) / 2
    
    # Iris Diameter (Pupil Proxy)
    i_left = get_point(lm, 474, w, h)
    i_right = get_point(lm, 476, w, h)
    iris_diam = np.linalg.norm(np.array(i_left) - np.array(i_right))
    
    return {
        'eye_center': eye_center,
        'eye_width': eye_width,
        'mouth_center': mouth_center,
        'face_center': face_center,
        'face_radius': face_radius,
        'iris_diameter': iris_diam
    }

# ── Main Loop ────────────────────────────────────────────────
def main():
    print("=" * 60)
    print("  ASD NEURO-DIAGNOSTIC SUITE (v2.0)")
    print("=" * 60)
    
    cap = cv2.VideoCapture(0)
    engine = ASDMetricsEngine()
    
    with mp_face_mesh.FaceMesh(refine_landmarks=True) as face_mesh:
        while cap.isOpened():
            ret, frame = cap.read()
            if not ret: break
            
            frame = cv2.flip(frame, 1)
            h, w, _ = frame.shape
            rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = face_mesh.process(rgb)
            
            if results.multi_face_landmarks:
                lm = results.multi_face_landmarks[0].landmark
                geom = get_face_geometry(lm, w, h)
                
                # Get Iris/Gaze Position
                i_l = get_point(lm, 473, w, h) # Left center
                i_r = get_point(lm, 468, w, h) # Right center
                iris_center_pos = ((i_l[0] + i_r[0]) // 2, (i_l[1] + i_r[1]) // 2)
                
                # Simulated Stimulus (Moving Dot for Gaze Following)
                t = time.time()
                stim_x = int(w/2 + np.cos(t) * (w/3))
                stim_y = int(h/2 + np.sin(t*0.5) * (h/4))
                stimulus_pos = (stim_x, stim_y)
                
                # Update Diagnostics
                engine.update(iris_center_pos, geom, w, h, stimulus_pos=stimulus_pos)
                report = engine.get_report()
                
                # --- Visualisasi Area ---
                # Social AOI (Face)
                cv2.circle(frame, geom['face_center'], int(geom['face_radius']), (50, 50, 50), 1)
                # Eye AOI
                cv2.circle(frame, geom['eye_center'], int(geom['face_radius']*0.3), (0, 255, 100), 1)
                # Mouth AOI
                cv2.circle(frame, geom['mouth_center'], int(geom['face_radius']*0.3), (0, 100, 255), 1)
                # Gaze Point
                cv2.drawMarker(frame, iris_center_pos, (255, 0, 255), cv2.MARKER_CROSS, 20, 2)
                # Stimulus (Target)
                cv2.circle(frame, stimulus_pos, 10, (255, 255, 255), -1)
                cv2.putText(frame, "FOLLOW ME", (stim_x-30, stim_y-20), 0, 0.4, (255, 255, 255), 1)
                
                # --- Dashboard Panel ---
                overlay = frame.copy()
                cv2.rectangle(overlay, (10, 10), (340, 280), (20, 20, 20), -1)
                cv2.addWeighted(overlay, 0.7, frame, 0.3, 0, frame)
                
                y0, dy = 40, 25
                cv2.putText(frame, "PANEL DIAGNOSTIK NEURO:", (20, y0), 0, 0.5, (0, 255, 255), 1)
                metrics_text = [
                    f"Durasi Fiksasi   : {report['avg_fixation']:.2f}s",
                    f"Preferensi Sos   : {report['social_preference']:.1f}%",
                    f"Atensi Mata (AOI): {report['aoi_eyes_pct']:.1f}%",
                    f"Atensi Mulut     : {report['aoi_mouth_pct']:.1f}%",
                    f"Kecepatan Sakade : {report['avg_saccade_vel']:.1f}px/f",
                    f"Akurasi Sakade   : {max(0, 100 - report['saccade_accuracy']/2):.1f}%",
                    f"Gaze Following   : {report['gaze_following']:.1f}%",
                    f"Latensi Respon   : {report['gaze_latency']:.2f}s",
                    f"Dilatasi Pupil   : {report['pupil_dynamic']*100:.2f}%",
                ]
                for i, text in enumerate(metrics_text):
                    color = (255, 255, 255)
                    if "Atensi Mata" in text and report['aoi_eyes_pct'] < 25: color = (100, 100, 255)
                    cv2.putText(frame, text, (20, y0 + (i+1)*dy), 0, 0.45, color, 1)
                
                # Visual Alert
                if report['social_preference'] < 40 and engine.total_frames > 150:
                    cv2.putText(frame, "ATENSI NON-SOSIAL TINGGI", (w//2-120, 50), 0, 0.6, (0, 0, 255), 2)

            cv2.imshow("NeuroAssist ASD Diagnostic", frame)
            if cv2.waitKey(1) & 0xFF == ord('q'): break

    cap.release()
    cv2.destroyAllWindows()
    
    # Summary Report
    final = engine.get_report()
    print("\n" + "=" * 60)
    print("  RINGKASAN DIAGNOSTIK (ASD BIOMARKERS)")
    print("-" * 60)
    print(f"  Fixation Stability : {'STABIL' if final['avg_fixation'] > 0.4 else 'RENDAH'}")
    print(f"  Social Preference  : {final['social_preference']:.1f}% ({'TINGGI' if final['social_preference'] > 60 else 'RENDAH'})")
    print(f"  Eye vs Mouth Ratio : {final['aoi_eyes_pct']:.1f}% / {final['aoi_mouth_pct']:.1f}%")
    print(f"  Saccade Accuracy   : {max(0, 100 - final['saccade_accuracy']/2):.1f}%")
    print(f"  Gaze Following     : {final['gaze_following']:.1f}%")
    print(f"  Pupil Reactivity   : {final['pupil_dynamic']:.4f} (Var)")
    print("=" * 60)

if __name__ == "__main__":
    main()