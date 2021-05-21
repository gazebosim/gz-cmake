A quick demonstration of searching for Ogre 2.1 vs 2.2 via ign-cmake.

To test with both versions installed:

## Ogre 2.1

```
cd ogre-2.1
mkdir build
cd build
cmake ..
```

### Expected output

```
-- Looking for IgnOGRE2 - found

-- OGRE2_FOUND: TRUE
-- OGRE2_LIBRARIES: /usr/lib/x86_64-linux-gnu/OGRE-2.1/libOgreMain.soIgnOGRE2-HlmsPbs::IgnOGRE2-HlmsPbsIgnOGRE2-HlmsUnlit::IgnOGRE2-HlmsUnlitIgnOGRE2-Overlay::IgnOGRE2-Overlay
-- OGRE2_INCLUDE_DIRS: /usr/include/OGRE-2.1/usr/include/OGRE-2.1/RenderSystems/GL3Plus
-- OGRE2_VERSION: 2.1.0
-- OGRE2_VERSION_MAJOR: 2
-- OGRE2_VERSION_MINOR: 1
-- OGRE2_VERSION_PATCH: 0
-- OGRE2_RESOURCE_PATH: /usr/lib/x86_64-linux-gnu/OGRE-2.1/OGRE
```

## Ogre 2.2

```
cd ogre-2.2
mkdir build
cd build
cmake ..
```

### Expected output


```
-- Looking for IgnOGRE2 - found

-- OGRE2_FOUND: TRUE
-- OGRE2_LIBRARIES: /usr/lib/x86_64-linux-gnu/OGRE-2.2/libOgreMain.soIgnOGRE2-HlmsPbs::IgnOGRE2-HlmsPbsIgnOGRE2-HlmsUnlit::IgnOGRE2-HlmsUnlitIgnOGRE2-Overlay::IgnOGRE2-Overlay
-- OGRE2_INCLUDE_DIRS: /usr/include/OGRE-2.2/usr/include/OGRE-2.2/RenderSystems/GL3Plus
-- OGRE2_VERSION: 2.2.6
-- OGRE2_VERSION_MAJOR: 2
-- OGRE2_VERSION_MINOR: 2
-- OGRE2_VERSION_PATCH: 6
-- OGRE2_RESOURCE_PATH: /usr/lib/x86_64-linux-gnu/OGRE-2.2/OGRE
```

