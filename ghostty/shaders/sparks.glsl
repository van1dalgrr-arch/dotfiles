// Искры при наборе: на каждую букву из-под курсора вылетает горстка искр и гаснет за долю секунды.
// Цвета — курсор и акцент палитры (5), так что тема и светлый режим подхватываются сами.

const float LIFE  = 0.42;   // сек, сколько живёт искра
const int   COUNT = 7;      // искр на одно нажатие

float hash(float n) { return fract(sin(n) * 43758.5453); }

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    fragColor = texture(iChannel0, fragCoord / iResolution.xy);

    float age = iTime - iTimeCursorChange;
    if (age >= LIFE || iFocus == 0) return;

    vec4 cur = iCurrentCursor, prev = iPreviousCursor;
    float cell = max(cur.w, 1.0);
    // только набор: курсор сдвинулся на 1–2 клетки по той же строке (прыжки рисует шлейф)
    float dx = cur.x - prev.x;
    if (abs(cur.y - prev.y) > 0.5 || abs(dx) < 0.5 || abs(dx) > cur.w * 1.6) return;

    // искры вылетают из клетки, где только что появилась буква (y вверх)
    vec2 origin = vec2(min(cur.x, prev.x) + abs(dx) * 0.5, cur.y - cell * 0.55);
    if (distance(fragCoord, origin) > cell * 4.0) return;    // дальше искры не долетают

    float t = age / LIFE;
    float seed = floor(iTimeCursorChange * 997.0);
    vec3 acc = vec3(0.0);
    for (int i = 0; i < COUNT; i++) {
        float fi = float(i) + seed;
        // веер вверх, чуть в сторону набора
        float ang = mix(0.35, 2.8, hash(fi * 1.7)) + sign(dx) * -0.25;
        float spd = cell * mix(3.0, 7.5, hash(fi * 3.1));
        vec2 vel = vec2(cos(ang), sin(ang)) * spd;
        vec2 p = origin + vel * age + vec2(0.0, -cell * 14.0) * age * age;   // гравитация
        float r = cell * mix(0.05, 0.1, hash(fi * 5.3)) * (1.0 - t * 0.6);
        float d = distance(fragCoord, p);
        float spark = (1.0 - smoothstep(r, r + 1.2, d)) + exp(-d / (r * 2.5)) * 0.45;
        vec3 col = mix(iCursorColor, iPalette[5], hash(fi * 7.9));
        acc += col * spark;
    }
    float fade = 1.0 - t * t;
    fragColor.rgb = mix(fragColor.rgb, min(acc, vec3(1.0)), clamp(length(acc) * fade, 0.0, 1.0));
}
