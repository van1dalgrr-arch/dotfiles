// Свечение текста: яркие буквы светятся своим цветом — мягкий ореол, как у неона, только аккуратно.
// В светлой теме выключается само (тёмный текст на белом светиться не должен).
// 16 выборок на пиксель — для M2 копейки, но это единственный эффект, который считается по всему окну.

const float STRENGTH = 0.55;
const float RADIUS   = 0.32;   // в высотах клетки
const int   TAPS     = 16;

// вклад выборки: только то, что заметно ярче фона (текст), а не фон и не картинка backdrop
vec3 bright(vec2 uv) {
    vec3 c = texture(iChannel0, uv).rgb;
    float m = max(c.r, max(c.g, c.b)) - max(iBackgroundColor.r, max(iBackgroundColor.g, iBackgroundColor.b));
    return c * smoothstep(0.3, 0.6, m);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord / iResolution.xy;
    fragColor = texture(iChannel0, uv);
    if (dot(iBackgroundColor, vec3(0.2126, 0.7152, 0.0722)) > 0.5) return;

    vec2 px = RADIUS * max(iCurrentCursor.w, 16.0) / iResolution.xy;
    // спираль Фогеля: радиусы и углы не повторяются — ореол без «двоения» букв
    vec3 sum = vec3(0.0);
    float wsum = 0.0;
    for (int i = 0; i < TAPS; i++) {
        float r = sqrt((float(i) + 0.5) / float(TAPS));
        float a = float(i) * 2.3999632;
        float w = 1.0 - r * 0.8;
        sum += bright(uv + vec2(cos(a), sin(a)) * r * px) * w;
        wsum += w;
    }
    fragColor.rgb += sum / wsum * STRENGTH;
}
