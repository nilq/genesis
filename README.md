# Genesis

Evolution of organisms powered by DWRAON (damp-weighted recurrent and/or network) brains, inspired by Andrej Karpathy's Script Bots.

There is currently no recording of the current version of Genesis. However, the following video shows a previous iteration of this project:

[![Video of simulation in progress.](https://img.youtube.com/vi/WKC0CCcwC-4/0.jpg)](https://www.youtube.com/watch?v=WKC0CCcwC-4)

## Getting started

This project runs on [LÖVE 0.10.0 (Super Toast)](https://love2d.org/wiki/0.10.0), and might have problems with colours in later versions.

Compile the [MoonScript](https://moonscript.org) code to Lua, then use LÖVE to run the simulation:


### Controls

#### Simulation

- Press `<space>` to spawn a randomly initialised organism at the mouse position.
- Press `<enter>` to spawn 10 random organisms at the mouse position.
- Press `<tab>` to run 1000 update steps without rendering (slightly faster this way).

#### Organisms 

- Left-click on an organism to select it. This will show a visualisation of the underlying brain and highlight organisms in its family.
- (with an organism already selected) Right-click on another organism to spawn a cross-over baby organism, merging properties of the selected and right-clicked organism.
- Press `<delete>` to kill selected agent.
- Press `<backspace>` to remove the selected agent as well as its entire family.


#### Food
- Left-click food grid to grow food at mouse position.
- Right-click food grid to remove food at mouse position.
