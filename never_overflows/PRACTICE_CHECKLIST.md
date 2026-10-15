1. RenderFlex experiment
   - Run the app.
   - Temporarily remove Expanded around the text Column in ContactCard.
   - Hot reload.
   - Find:
     "A RenderFlex overflowed by N pixels on the right"
   - Record the real N in the comment above Row.
   - Restore Expanded.

2. Unbounded-height experiment
   - Temporarily remove Expanded around ListView.separated.
   - Hot reload.
   - Verify the error:
     "Vertical viewport was given unbounded height"
   - Restore Expanded.

3. Stack experiment
   - Temporarily put the Positioned badge BEFORE CircleAvatar in Stack.children.
   - Hot reload.
   - Take a screenshot showing the badge underneath the avatar.
   - Save it in the PROJECT ROOT as:
     stack_swapped.png
   - Restore the correct Stack order.

4. Final light screenshot
   - Switch device/system to light mode.
   - Run the final app.
   - Save screenshot in PROJECT ROOT as:
     screenshot_light.png

5. Final dark screenshot
   - Switch device/system to dark mode.
   - Run the final app.
   - Save screenshot in PROJECT ROOT as:
     screenshot_dark.png
