# loudness

Ruby script to automate EBU R128 loudness normalization using FFmpeg's <a href="https://ffmpeg.org/ffmpeg-filters.html#loudnorm">loudnorm</a> filter.
Give four arguments to specify the standard of normalization you're trying to reach:
```bash
$ ruby loudness.rb input.wav output.wav -23 +11 -2 '48k'
```
