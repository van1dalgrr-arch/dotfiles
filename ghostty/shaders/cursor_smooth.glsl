// Плавный курсор как в VS Code: настоящий скрыт (cursor-opacity = 0), этот шейдер рисует его
// и ведёт к новой позиции. Выключить — убрать cursor-opacity и этот custom-shader в config.ghostty.

const float BASE_DURATION = 0.07;   // сек на короткий шаг (одна буква)
const float PER_CELL      = 0.012;  // + за каждую клетку расстояния
const float MAX_DURATION  = 0.16;

float easeOut(float x) { return 1.0 - pow(1.0 - x, 3.0); }

// маска прямоугольника с мягким краем; r.xy — левый верхний угол (ось y вверх), r.zw — размер
float rectMask(vec2 p, vec4 r) {
    vec2 lo = vec2(r.x, r.y - r.w), hi = vec2(r.x + r.z, r.y);
    vec2 d = max(lo - p, p - hi);
    return 1.0 - smoothstep(-0.5, 0.5, max(d.x, d.y));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 base = texture(iChannel0, fragCoord / iResolution.xy);
    fragColor = base;

    vec4 cur = iCurrentCursor, prev = iPreviousCursor;
    if (cur.z < 0.5 || cur.w < 0.5) return;                // курсора нет (скрыт программой)

    float cell = max(cur.w, 1.0);
    float dist = distance(cur.xy, prev.xy);
    float dur  = min(BASE_DURATION + PER_CELL * dist / cell, MAX_DURATION);
    float t    = clamp((iTime - iTimeCursorChange) / dur, 0.0, 1.0);
    bool moving = t < 1.0 && dist > 0.5 && prev.z > 0.5;

    // мигание — как решил Ghostty; во время движения курсор виден всегда
    if (iCursorVisible == 0 && !moving) return;

    vec4 r = cur;
    if (moving) {
        float e = easeOut(t);
        r = vec4(mix(prev.xy, cur.xy, e), mix(prev.zw, cur.zw, e));
    }
    float m = rectMask(fragCoord, r);
    if (m <= 0.0) return;

    vec3 cc = iCursorColor;
    if (iFocus == 0) {                                      // окно не в фокусе — полый блок
        m *= 1.0 - rectMask(fragCoord, vec4(r.x + 1.0, r.y - 1.0, r.z - 2.0, r.w - 2.0));
        fragColor.rgb = mix(base.rgb, cc, m);
        return;
    }
    if (iCurrentCursorStyle == CURSORSTYLE_BLOCK) {
        // блок: фон клетки — цветом курсора, сам символ — цветом текста под курсором
        float isText = smoothstep(0.08, 0.25, distance(base.rgb, iBackgroundColor));
        fragColor.rgb = mix(base.rgb, mix(cc, iCursorText, isText), m);
    } else {
        fragColor.rgb = mix(base.rgb, cc, m);
    }
}
