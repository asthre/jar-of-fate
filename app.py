import streamlit as st
import random
import time
import pandas as pd

# --- 1. CONFIG & STYLE (Your Mobile Theme) ---
st.set_page_config(page_title="Jar of Fate", page_icon="⚱️", layout="centered")

# Your exact colors from Flutter
BG_COLOR = "#1A1A2E"
BG_GRADIENT_END = "#16213E"
GOLD = "#FFD700"
PURPLE = "#6C63FF"
CARD_BG = "#252545"

# Custom CSS to force the Mobile Look
st.markdown(f"""
    <style>
    /* Force Background Color */
    .stApp {{
        background: linear-gradient(to bottom, {BG_COLOR}, {BG_GRADIENT_END});
        color: white;
    }}
    
    /* Styled Containers (Cards) */
    .css-1r6slb0, .stContainer {{
        background-color: {CARD_BG};
        border-radius: 20px;
        border: 1px solid rgba(255,255,255,0.1);
    }}

    /* The "Gold" Highlights */
    .gold-text {{
        color: {GOLD};
        font-weight: bold;
        font-size: 24px;
    }}

    /* Custom Buttons (Purple) */
    .stButton>button {{
        background-color: {PURPLE};
        color: white;
        border-radius: 30px;
        border: none;
        padding: 10px 24px;
        font-weight: bold;
    }}
    
    /* Hide the standard header to make it look like an app */
    header {{visibility: hidden;}}
    </style>
""", unsafe_allow_html=True)

# --- 2. SESSION STATE (Memory) ---
if 'jar_items' not in st.session_state:
    st.session_state.jar_items = []
if 'sponty_items' not in st.session_state:
    st.session_state.sponty_items = []
if 'show_list_sheet' not in st.session_state:
    st.session_state.show_list_sheet = False
if 'result_view' not in st.session_state:
    st.session_state.result_view = None # Stores the winner item if we are looking at a result

# --- 3. HELPER FUNCTIONS ---
def add_jar_item(item):
    if item:
        st.session_state.jar_items.append(item)

def add_sponty_item(item):
    if item:
        st.session_state.sponty_items.append(item)

# --- 4. APP LAYOUT ---

# Top Bar (Mimicking AppBar)
col1, col2 = st.columns([3, 1])
with col1:
    mode = st.selectbox("Mode", ["⚱️ Jar of Fate", "🎡 Sponty Wheel"], label_visibility="collapsed")

with col2:
    # The "Action Button" in top right
    if "Jar" in mode:
        if st.button("📜 List", help="View Jar Contents"):
            # Toggle the 'Bottom Sheet' view
            st.session_state.show_list_sheet = not st.session_state.show_list_sheet
    else:
        if st.button("🗑️ Clear"):
            st.session_state.sponty_items = []
            st.rerun()

st.divider()

# --- 5. LOGIC SWITCHER ---

# ==========================
# VIEW: THE LIST (Bottom Sheet style)
# ==========================
if st.session_state.show_list_sheet and "Jar" in mode:
    st.markdown("### 📜 Inside the Jar")
    if not st.session_state.jar_items:
        st.info("The jar is empty.")
    else:
        # Display items with delete buttons
        for i, item in enumerate(st.session_state.jar_items):
            c1, c2 = st.columns([4, 1])
            c1.markdown(f"**{item}**")
            if c2.button("❌", key=f"del_{i}"):
                st.session_state.jar_items.pop(i)
                st.rerun()
    
    if st.button("Close List"):
        st.session_state.show_list_sheet = False
        st.rerun()

# ==========================
# VIEW: THE RESULT (Dialog Overlay)
# ==========================
elif st.session_state.result_view:
    # This block mimics your "AlertDialog"
    st.markdown(f"""
    <div style="background-color: {CARD_BG}; padding: 30px; border-radius: 20px; text-align: center; border: 2px solid {GOLD};">
        <h2 style="color: white; margin-bottom: 0;">The Fates Decided:</h2>
        <h1 style="color: {GOLD}; font-size: 50px; margin-top: 10px;">{st.session_state.result_view}</h1>
    </div>
    """, unsafe_allow_html=True)
    
    st.write("") # Spacer
    
    b1, b2 = st.columns(2)
    with b1:
        if st.button("Keep it", use_container_width=True):
            st.session_state.result_view = None # Close dialog
            st.rerun()
    with b2:
        if st.button("Done & Remove", use_container_width=True):
            # Try to remove if it exists (Jar mode logic)
            if st.session_state.result_view in st.session_state.jar_items:
                st.session_state.jar_items.remove(st.session_state.result_view)
            st.session_state.result_view = None # Close dialog
            st.rerun()

# ==========================
# VIEW: JAR MODE (Main)
# ==========================
elif "Jar" in mode:
    # Visual Jar Container
    st.markdown(f"""
    <div style="
        height: 250px; 
        background-color: rgba(255,255,255,0.05); 
        border: 2px solid rgba(255,255,255,0.2);
        border-radius: 20px 20px 50px 50px;
        display: flex; flex-direction: column; align-items: center; justify-content: center;
        margin-bottom: 20px; box-shadow: 0px 0px 30px rgba(108, 99, 255, 0.2);">
        <div style="font-size: 50px; opacity: 0.5;">⚱️</div>
        <div style="font-size: 60px; font-weight: bold; color: white;">{len(st.session_state.jar_items)}</div>
        <div style="color: rgba(255,255,255,0.5);">Items</div>
    </div>
    """, unsafe_allow_html=True)

    # The "Pick" Button
    center_col = st.columns([1,2,1])
    with center_col[1]:
        if st.session_state.jar_items:
            if st.button("🔮 LEARN YOUR FATE", use_container_width=True):
                with st.spinner("The Jar is trembling..."):
                    time.sleep(1.5) # Animation delay
                    winner = random.choice(st.session_state.jar_items)
                    st.session_state.result_view = winner
                    st.rerun()
        else:
            st.markdown("<center style='opacity:0.5'>Jar is empty...</center>", unsafe_allow_html=True)

    # Input Bar (Fixed at bottom like chat)
    new_item = st.chat_input("Add to jar...")
    if new_item:
        add_jar_item(new_item)
        st.rerun()

# ==========================
# VIEW: SPONTY MODE (Wheel)
# ==========================
else:
    # Using a chart to simulate the wheel visual
    if len(st.session_state.sponty_items) < 2:
        st.markdown(f"""
        <div style="height: 300px; display:flex; align-items:center; justify-content:center; color:rgba(255,255,255,0.3);">
            <h3>🎡 Add at least 2 items!</h3>
        </div>
        """, unsafe_allow_html=True)
    else:
        # Simple Visual Representation of items
        st.write("Current Options:")
        # We can't do a real spinning wheel easily in basic Streamlit, 
        # so we show the options as tags
        st.markdown(" ".join([f"`{x}`" for x in st.session_state.sponty_items]))
        
        st.write("")
        if st.button("SPIN IT ⚡", use_container_width=True):
             with st.spinner("Spinning..."):
                time.sleep(2)
                winner = random.choice(st.session_state.sponty_items)
                st.session_state.result_view = winner
                st.rerun()

    # Input Bar (Fixed at bottom)
    new_opt = st.chat_input("Add wheel option...")
    if new_opt:
        add_sponty_item(new_opt)
        st.rerun()