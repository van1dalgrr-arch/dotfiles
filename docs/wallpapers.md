# Wallpapers

Every wallpaper is a Swift script in [`icons/`](../icons) that paints a scene in code at screen resolution
(2560×1664) and renders a dynamic HEIC: 12 frames through the day, macOS blends between them.
Apply one with `wall <name>`, or run `wall` to pick from a list with image previews.
`backdrop <name>` puts a dark, readable version of any of them behind the terminal.

Previews show the hour that suits each scene best.

## Dark anime

<table>
<tr><td width="33%" valign="top"><img src="wallpapers/ghoulnight.jpg" alt="ghoulnight"/><br><b><code>ghoulnight</code></b><br><sub>A city in the rain under a huge red moon; on the roof edge, a silhouette with one red eye and four tendrils (an original character)</sub></td><td width="33%" valign="top"><img src="wallpapers/rainalley.jpg" alt="rainalley"/><br><b><code>rainalley</code></b><br><sub>A narrow Tokyo alley in the rain: neon signs without readable text, a vending machine, reflections on wet asphalt</sub></td></tr>
</table>

## Japan

<table>
<tr><td width="33%" valign="top"><img src="wallpapers/torii.jpg" alt="torii"/><br><b><code>torii</code></b><br><sub>Stone steps climbing into fog through red torii gates, stone lanterns and cedars; the lanterns light up at night</sub></td><td width="33%" valign="top"><img src="wallpapers/sakuranight.jpg" alt="sakuranight"/><br><b><code>sakuranight</code></b><br><sub>Cherry branches, a full moon, a string of paper lanterns and falling petals</sub></td><td width="33%" valign="top"><img src="wallpapers/hanami.jpg" alt="hanami"/><br><b><code>hanami</code></b><br><sub>Cherry blossom at dusk over a bridge and dark water; a lamp comes on at night</sub></td></tr>
</table>

## Twilight

<table>
<tr><td width="33%" valign="top"><img src="wallpapers/twilight.jpg" alt="twilight"/><br><b><code>twilight</code></b><br><sub>Anime dusk: towering clouds lit from below, power lines and a small town in silhouette</sub></td><td width="33%" valign="top"><img src="wallpapers/crossing.jpg" alt="crossing"/><br><b><code>crossing</code></b><br><sub>A railway crossing at dusk: rails to the horizon, the red signal blinking, wires along the track</sub></td></tr>
</table>

## Fog & weather

<table>
<tr><td width="33%" valign="top"><img src="wallpapers/mistcity.jpg" alt="mistcity"/><br><b><code>mistcity</code></b><br><sub>Panel high-rises sinking into blue fog, wires, a fence and warm windows that light up floor by floor</sub></td><td width="33%" valign="top"><img src="wallpapers/snowfall.jpg" alt="snowfall"/><br><b><code>snowfall</code></b><br><sub>A courtyard in a snowstorm: tall blocks in the haze, snow-laden branches, flakes in three depths</sub></td><td width="33%" valign="top"><img src="wallpapers/cosmea.jpg" alt="cosmea"/><br><b><code>cosmea</code></b><br><sub>A field of pink cosmos fading into thick fog, a few tall stems in focus</sub></td></tr>
<tr><td width="33%" valign="top"><img src="wallpapers/steppe.jpg" alt="steppe"/><br><b><code>steppe</code></b><br><sub>Tall grass bent by the wind, the hill dissolving into mist</sub></td></tr>
</table>

## Your photos

`wall add <photo> [name]` adds any picture (for example anime art you downloaded for yourself). Photos live in the
git-ignored `wallpapers/photos/` and never reach the public repo; `backdrop <name>` works for them too.

## Make your own

Create `icons/wallpaper-<name>.swift` with `runWallpaper { hour in … }` and run `wall <name>`.
`icons/wallpaper-kit.swift` has the building blocks: `haze` (fog between planes), `soften` (depth of field),
`blurLayer`, `filmic` (grain and vignette), `bloom`, `lamp`, `stars`, panel `tower`s, `wire`s and sakura `blossomTree`s.
