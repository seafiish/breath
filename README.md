have you ever been super annoyed at how Bandcamp encodes it's flac metadata by default? no? well I have, so I fixed it

#### don't programs like mp3tag or puddletag let you automate actions to do this anyway?  
uhhh yes I think so, but shh I was bored and wanted to make something.  
also I want to add optional opus encoding so that will be unique when that's out  

#### isn't zig super overkill for this?  
I just enjoy writing zig code :3

### FEATURES
runs metaflac CLI to:  
a) add ALBUM & ALBUMARTIST tags to .flac metadata for single tracks  
b) replaces UNSYNCEDLYRICS tag with LYRICS for better compatability  
for every track in your collection!

### INSTALLATION
requires metaflac https://xiph.org/flac/documentation_tools_metaflac.html  
just download the release binary for your OS/architecture

### BUILD FROM SOURCE
use version 0.14.1 of the Zig Compiler <add link>  
just clone and zig build

```
  git clone https://github.com/seafiish/breath.git
  cd breath
  zig build
```

### USAGE
download music in .flac from bandcamp in the same folder as the binary and run it

### TODO
figure out whether or not the bandcamp embedded cover encoding is correct or not  
test if this works on windows, figure out how to test if this works on mac  

add real opus encoding (!)  
maybe add support for other encoding as well, need to figure out how good/bad bandcamp's encoding tools are for the formats they do offer
