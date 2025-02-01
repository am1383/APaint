🎨 APaint - Assembly Final Project

APaint is a simple graphics-based drawing program written in x86 Assembly. It allows users to draw, erase, and switch between colors using a mouse interface in VGA mode 13h (320x200, 256 colors).
📌 Features

✅ Graphical Mode (320x200, 256 colors)
✅ Mouse Input Support
✅ Color Selection (White, Blue, Green, Red)
✅ Draw Lines (Using Bresenham’s Algorithm)
✅ Erase Pixels
✅ Custom Macros for Screen Control
🛠 How It Works
🎨 Drawing

    Right Click: Selects the start point of a line.
    Right Click Release: Selects the end point and draws a line using Bresenham’s Line Algorithm.
    Left Click: Erases the pixel under the cursor.

🎨 Color Selection

    Click in the color palette area (top 80 rows of the screen) to change the current drawing color.

🏗️ How to Run
Requirements

🖥 DOSBox or an actual MS-DOS environment
⚙️ TASM/MASM (for assembling the code)
Steps

1️⃣ Assemble the code:

tasm apaint.asm
tlink apaint.obj

2️⃣ Run the executable:

apaint.exe

🏗️ Project Structure

    Macros Section
        CLEAR_SCREEN: Clears the screen.
        DISPLAY_MESSAGE: Displays text on the screen.
        SET_CURSOR: Moves the text cursor.
        FILL_PIXEL: Draws a pixel at the current position.
        DRAW_COLOR_BOX: Draws a block of color.
        SWITCH_COLOR: Changes the paint color based on the cursor position.

    Main Program (MAIN PROC)
        Initializes the video mode and mouse driver.
        Displays the welcome message.
        Handles mouse input for drawing and erasing.

    Functions
        DRAW_LINE: Draws a line using Bresenham's Algorithm.
        DRAW_HLINE: Handles horizontal lines.
        DRAW_VERTICAL: Handles vertical lines.
        ERASER: Clears pixels around the cursor.

📌 Future Improvements

🔹 Save and Load drawings.
🔹 More colors and shapes.
🔹 Fill tool for coloring closed areas.
