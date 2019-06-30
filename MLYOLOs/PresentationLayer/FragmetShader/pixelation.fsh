void main() {
    // 1秒で１周期
    float time = mod(u_time, 10.0);
    float sinVala = sin(time) + 5;
    
    float sinVal = sin(time * 0.14) + sinVala;
    
    vec2 one_over_size = 1.0 / 100 * (sin(time*0.04)+0.1*sin(time)+0.4);
    
    float pixel_x = sinVal * 1.5 * one_over_size.x;
    float pixel_y = sinVal * one_over_size.y;

    float coord_x = pixel_x * floor(v_tex_coord.x / pixel_x + 0.5);
    float coord_y = pixel_y * floor(v_tex_coord.y / pixel_y + 0.5);
    
    vec4 c;
    c = texture2D(u_texture, vec2(coord_x, coord_y));
    
    gl_FragColor = c * v_color_mix.a;
}
