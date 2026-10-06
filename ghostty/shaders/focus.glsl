// Вспышка фокуса: окно, получившее фокус, на полсекунды подсвечивается по краям цветом курсора.
// С AeroSpace сразу видно, куда ушёл фокус после alt+стрелки.

const float DURATION = 0.55;   // сек

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    float t = (iTime - iTimeFocus) / DURATION;
    if (iFocus == 0 || t >= 1.0 || t < 0.0) return;

    // единица — высота клетки, чтобы на Retina и без неё выглядело одинаково
    float unit = max(iCurrentCursor.w, 16.0);
    vec2 p = fragCoord, s = iResolution.xy;
    float edge = min(min(p.x, s.x - p.x), min(p.y, s.y - p.y));

    // свет нарастает за первую десятую и плавно уходит
    float env = smoothstep(0.0, 0.1, t) * pow(1.0 - t, 2.0);
    float rim  = exp(-edge / (unit * 0.12));          // тонкая яркая кромка
    float halo = exp(-edge / (unit * 1.4)) * 0.35;    // мягкое сияние внутрь
    // по кромке бежит блик сверху вниз — чтобы вспышка не была плоской
    float sweep = 0.6 + 0.4 * smoothstep(0.25, 0.0, abs(1.0 - p.y / s.y - t * 1.6));

    vec3 col = mix(iCursorColor, iPalette[4], p.x / s.x * 0.6);
    fragColor.rgb = mix(fragColor.rgb, col, clamp((rim + halo) * sweep * env, 0.0, 0.9));
}
