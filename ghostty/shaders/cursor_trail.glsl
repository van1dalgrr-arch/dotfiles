// Светящийся шлейф на больших прыжках курсора. Цвета — // #hex, их перекрашивает themes/apply.sh

const float DURATION = 0.28;                       // сек
const vec3  ROSE     = vec3(0.922, 0.737, 0.729);  // #ebbcba
const vec3  IRIS     = vec3(0.769, 0.655, 0.906);  // #c4a7e7

float easeOut(float x) { return 1.0 - pow(1.0 - x, 3.0); }

// Расстояние до отрезка a→b; h — позиция вдоль отрезка (0..1)
float segment(vec2 p, vec2 a, vec2 b, out float h) {
    vec2 pa = p - a, ba = b - a;
    h = clamp(dot(pa, ba) / max(dot(ba, ba), 1e-4), 0.0, 1.0);
    return length(pa - ba * h);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    // xy — левый верхний угол курсора, zw — размер; ось y смотрит вверх
    vec2 cur  = iCurrentCursor.xy  + vec2(iCurrentCursor.z,  -iCurrentCursor.w)  * 0.5;
    vec2 prev = iPreviousCursor.xy + vec2(iPreviousCursor.z, -iPreviousCursor.w) * 0.5;
    float cell = max(iCurrentCursor.w, 1.0);

    float t = clamp((iTime - iTimeCursorChange) / DURATION, 0.0, 1.0);
    if (t >= 1.0 || distance(cur, prev) < cell * 1.5) return;

    // хвост догоняет курсор
    vec2 tail = mix(prev, cur, easeOut(t));
    float h;
    float d = segment(fragCoord, tail, cur, h);

    float fade  = 1.0 - t;
    float width = cell * mix(0.08, 0.32, h);       // тонкий хвост, толстая голова
    float core  = 1.0 - smoothstep(width - 1.0, width + 1.0, d);
    float glow  = exp(-d / (cell * 0.6)) * 0.35;

    vec3 color = mix(IRIS, ROSE, h);
    float a = clamp((core * 0.85 + glow) * fade, 0.0, 1.0);
    fragColor.rgb = mix(fragColor.rgb, color, a);
}
