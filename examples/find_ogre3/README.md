A quick demonstration of searching for Ogre 3.0 via gz-cmake.

To test with the pkg-config and the specified version of Ogre installed:

## Ogre 3.0

```
cd ogre-3.0
mkdir build
cd build
PKG_CONFIG_PATH=/usr/local/lib/pkgconfig/ cmake ..
```

### Expected output

```
-- Finding OGRE 3.0
-- Looking for OGRE3 using the name: OGRE
--   + component HlmsPbs: found
--   + component HlmsUnlit: found
--   + component Overlay: found
--   + component Atmosphere: found
-- Looking for GzOGRE3 - found

-- OGRE3_FOUND: 1
-- OGRE3_LIBRARIES: /usr/local/lib/libOgreMain_d.soGzOGRE3-HlmsPbs::GzOGRE3-HlmsPbsGzOGRE3-HlmsUnlit::GzOGRE3-HlmsUnlitGzOGRE3-Overlay::GzOGRE3-OverlayGzOGRE3-Atmosphere::GzOGRE3-Atmosphere
-- OGRE3_INCLUDE_DIRS: /usr/local/include/usr/local/include/OGRE/usr/local/include/usr/local/include/OGRE/RenderSystems/GL3Plus
-- OGRE3_VERSION: 3.0.0
-- OGRE3_VERSION_MAJOR: 3
-- OGRE3_VERSION_MINOR: 0
-- OGRE3_VERSION_PATCH: 0
-- OGRE3_RESOURCE_PATH: /usr/local/lib/OGRE
-- GzOGRE3_VERSION_EXACT: TRUE
-- GzOGRE3_VERSION_COMPATIBLE: TRUE
```
