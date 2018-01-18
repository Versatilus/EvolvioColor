# EvolvioColor
Artificial life toy based on work by @carykh

This program, evolv.io, is the product and focus of a series of videos by the YouTuber [@carykh](https://www.youtube.com/user/carykh/search?query=evolv.io). Several of the videos focus on poor performance he was trying to overcome. Running with the Java profiler VisualVM, I found that the program was spending the vast majority of its time rendering. Processing 3 still uses the AWT for rendering by default. Things run much more smoothly with a more modern renderer.

This is the bleeding edge of my developments. The code is vastly under commented and very rough around the edges. I'm (re-) learning both Java and Processing as I go along. I intend to be more methodical and organized as I progress.

The code was released "open source" but without a specific license, so take that Apache license with a grain of salt.
