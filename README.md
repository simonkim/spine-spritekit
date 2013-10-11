spine-spritekit
===============

Unofficial iOS 7 SpriteKit Runtime for Spine 2D (http://esotericsoftware.com)

Official runtimes are here: http://esotericsoftware.com/spine-runtimes

I wrote a quick code for my own project that uses SpriteKit and Spine 2D at the same time. 
Though it does not fully support all the features of Spine 2D, it basically,
- Places Bones and Skot Attachments on SKScene (SpriteKit Scene object)
- Animates Bone Timelines using SKAction for translate, rotate, and scale sequences

Until the official release of SpriteKit Runtime from esoteric software, hope it's a quick starter for your projects if you are considering use of Spine and SpriteKit at the same time.

Feel free to fork and send pull requests!

# Building and running
## Don't forget to init and update submodule for spine-runtimes, which is the offcial runtimes, once you've cloned this project
<pre>
$ git clone https://github.com/simonkim/spine-spritekit

$ git submodule init

$ git submodule update
</pre>

## Open the demo project from Xcode 5
- Located at Spine-Spritekit-Demo/Spine-Spritekit-Demo.xcodeproject
- Build and run

# Screenshots

![iPad](https://raw.github.com/simonkim/spine-spritekit/43396b75aa283d6cc7fe6a2bfc9e53a7f6f375ee/Screenshots/iPad.png)
![iPhone](https://raw.github.com/simonkim/spine-spritekit/43396b75aa283d6cc7fe6a2bfc9e53a7f6f375ee/Screenshots/iPhone.png)
