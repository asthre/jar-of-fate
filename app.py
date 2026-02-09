import streamlit as st
import random
import time

# --- PAGE SETUP ---
st.set_page_config(
    page_title="Jar of Fate",
    page_icon="🔮",
    layout="centered",
    initial_sidebar_state="collapsed"
)

# --- CUSTOM CSS FOR THE "JAR VIBE" ---
st.markdown("""
    <style>
    /* Main Background - Dark like the screenshot */
    .stApp {
        background-color: #121212;
        color: #E0E0E0;
    }

    /* The "Jar" Container Area */
    .jar-container {
        background: linear-gradient(135deg, #6200EA, #3700B3); /* Purple gradient */
        padding: 30px;
        border-radius: 25px;
        text-align: center;
        box-shadow: 0 10px 20px rgba(0,0,0,0.3);
        margin-bottom: 25px;
        border: 2px solid #7C4DFF;
    }

    /* The Button Styling */
    div.stButton > button {
        width: 100%;
        background: linear-gradient(90deg, #7C4DFF, #651FFF); /* Lighter purple */
        color: white;
        border: none;
        padding: 15px 32px;
        text-align: center;
        text-decoration: none;
        display: inline-block;
        font-size: 18px;
        font-weight: bold;
        margin: 4px 2px;
        cursor: pointer;
        border-radius: 15px;
        box-shadow: 0 4px 10px rgba(124, 77, 255, 0.3);
        transition: all 0.3s ease;
    }
    div.stButton > button:hover {
         background: linear-gradient(90deg, #651FFF, #7C4DFF);
         transform: translateY(-2px);
    }

    /* Input Text Area Styling */
    .stTextArea textarea {
        background-color: #1E1E1E;
        color: #E0E0E0;
        border-radius: 15px;
        border: 1px solid #333;
    }

    /* Headings */
    h1 { color: #B388FF !important; font-weight: 800; }
    h3 { color: #D1C4E9 !important; }
    </style>
    """, unsafe_allow_html=True)

# --- HEADER ---
st.title("🔮 Jar of Fate")
st.markdown("### Leave your destiny to the jar.")

# --- THE "JAR" VISUAL AREA ---
# This creates the purple box look from the screenshot
st.markdown("""
<div class="jar-container">
    <h2 style='color: white; margin:0;'>The Jar</h2>
    <p style='color: #D1C4E9;'>Waiting for items...</p>
    <h1 style='font-size: 60px; margin: 10px 0;'>∞</h1>
</div>
""", unsafe_allow_html=True)


# --- INPUT SECTION ---
st.write("📥 **Add to jar...** (Enter one choice per line)")
user_input = st.text_area(" ", height=120, placeholder="E.g.\nEat\nSleep\nCode\nRepeat")


# --- LOGIC & REVEAL ---
# Using a centered column for the button to look more like mobile
col1, col2, col3 = st.columns([1, 2, 1])

with col2:
    if st.button("SHAKE THE JAR ✨"):
        # Process input
        options = [line.strip() for line in user_input.split('\n') if line.strip()]
        
        if len(options) < 2:
            st.error("⚠️ Please add at least two items to the jar!")
        else:
            # Suspense
            with st.spinner("Shaking..."):
                time.sleep(1.5)
            
            # Result
            choice = random.choice(options)
            
            # Dramatic Reveal Overlay
            st.markdown(f"""
                <div style="
                    position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
                    background: rgba(0,0,0,0.9); padding: 40px; border-radius: 20px;
                    text-align: center; z-index: 9999; border: 3px solid #76ff03;
                    box-shadow: 0 0 30px #76ff03;">
                    <h3 style='color: #E0E0E0;'>The Jar has spoken:</h3>
                    <h1 style='color: #76ff03; font-size: 70px; margin-top: 10px; text-transform: uppercase;'>{choice}</h1>
                    <p style='color: #E0E0E0; margin-top: 20px;'>Click anywhere to close</p>
                </div>
            """, unsafe_allow_html=True)
            st.snow()

# --- FOOTER ---
st.write("---")
st.caption("🔮 Jar of Fate | Created by Asthre")