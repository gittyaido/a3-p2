
uniform vec3 resolution;   
uniform float time;   
uniform vec3 camPos;   

uniform vec3 movement;

// NOTE: modify these to control performance/quality tradeoff
#define MAX_STEPS 50 // max number of steps to take along ray
#define MAX_DIST 50. // max distance to travel along ray

#define HIT_DIST .01 // distance to consider as "hit" to surface
#define PUMPKIN_CENTER vec3(0,1,5) 

/*
 * Helper: rotate point p around Z axis by angle (in degrees).
 */
vec3 rotZ(vec3 p, float angle) {
    float s = sin(radians(angle));
    float c = cos(radians(angle));
    return mat3(
        c, -s, 0,
        s, c, 0.0,
        0, 0, 1) * p; 
}

/*
 * Helper: determines the material ID based on the closest distance.
 */
float getMaterial(vec2 d1, vec2 d2) {
    return (d1.x < d2.x) ? d1.y : d2.y;
}

/*
 * Hard union of two SDFs.
 */
float unionSDF( float d1, float d2 )
{
	/*
     * TODO: Implement the union of two SDFs.
     */

    return min(d1, d2);
}

/*
 * Hard difference of two SDFs.
 */
float subtractionSDF(float d1, float d2)
{   
	/*
     * TODO: Implement the union of two SDFs.
     */
    return max(d1, -d2);

    return 0.0;
}   

/*
 * Smooth union of two SDFs.
 * Resource: `https://iquilezles.org/articles/smin/`
 */
float smoothUnionSDF( float d1, float d2, float k )
{
	/*
     * TODO: Implement the smooth union of two SDFs.
     */
    k *= 2.0;
    float x = (d2-d1)/k;
    float g = 0.5*(x+sqrt(x*x+1.0));
    return d2 - k * g;

    // return unionSDF(d1, d2); // Placeholder for smooth union SDF
    // return 0.0;
}

/*
 * Smooth difference of two SDFs.
 */
float smoothSubtractionSDF(float d1, float d2, float k)
{
    /*
     * TODO: Implement the smooth union of two SDFs.
     * HINT: you may be able to use smoothUnionSDF
     */
    return -smoothUnionSDF(-d1, d2, k);
}


/*
 * Computes the signed distance function (SDF) of a plane.
 * https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the plane.
 *    - An identifier for material type.
 */
vec2 Plane(vec3 p)
{
    vec3 n = vec3(0, 1, 0); // Normal of the plane
    float h = 0.0; // Height offset
    return vec2(dot(p, n) + h, 1.0);
}

/*
 * Sphere SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the sphere.
 *  - r: The radius of the sphere.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the sphere.
 *    - An identifier for material type.
 */
vec2 Sphere(vec3 p, vec3 c, float r)
{
    /*
     * TODO: Implement the signed distance function for a sphere.
    */
    float dist = length(p - c) - r;

    return vec2(dist, 2.0);
}

/*
 * Cylinder SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the cylinder.
 *  - r: The radius of the cylinder.
 *  - h: The height of the cylinder.
 *  - angle: Degree of rotation.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the cylinder.
 *    - An identifier for material type.
 */
vec2 Cylinder(vec3 p, vec3 c, float r, float h, float angle)
{
    /*
     * TODO: Implement the signed distance function for a cylinder.
     */
    // Move cylinder center to origin
    vec3 q = p - c;

    // Rotate around Z axis
    q = rotZ(q, angle);

    // Distance from curved side
    float radialDist = length(q.xz) - r;

    // Distance from top/bottom caps
    float verticalDist = abs(q.y) - h * 0.5;

    // Combine distances
    vec2 d = vec2(radialDist, verticalDist);

    float dist = min(max(d.x, d.y), 0.0) + length(max(d, 0.0));

    return vec2(dist, 3.0);

}

/*
 * Traingular Prism SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the prism.
 *  - dim: heigh and width of the prism (vec2).
 *  - angle: Degree of rotation.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the prism.
 *    - An identifier for material type.
 */
vec2 TriPrism( vec3 p, vec3 c, vec2 dim, float angle )
{
    vec3 localPoint = rotZ(p - c, angle);
    vec3 q = abs(localPoint);

    float dist = max(
        q.z - dim.y,
        max(q.x * 0.866025 + localPoint.y * 0.5, -localPoint.y) - dim.x * 0.5
    );

    return vec2(dist, 3.0);
}

/*
 * Rectangular Prism SDF. https://iquilezles.org/articles/distfunctions/
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *  - c: The center of the rectangular prism.
 *  - dim: length, height, width of the rectangular prism (vec3).
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the rectangular prism.
 *    - An identifier for material type.
 */
vec2 RectPrism( vec3 p, vec3 c , vec3 dim )
{
    /*
     * TODO: Implement the signed distance function for a rectangular prism.
     */
    // Translate point relative to box center
    vec3 q = p - c;

    // Distance to each box boundary
    vec3 d = abs(q) - dim;

    // Distance outside the box
    float outside = length(max(d, 0.0));

    // Distance inside the box
    float inside = min(max(d.x, max(d.y, d.z)), 0.0);

    float dist = outside + inside;

    return vec2(dist, 2.0);
}

/*
 * Pumpkin SDF. Centered at PUMPKIN_CENTER.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the surface of the pumpkin.
 *    - An identifier for material type.
 */

vec2 Pumpkin(vec3 p)
{
    vec3 c = PUMPKIN_CENTER;

    // 1. Pumpkin body
    vec2 body = Sphere(p, c, 1.0);

    // Slightly flatten the body vertically
    // This stretches the sphere into a pumpkin-like shape
    vec3 squashP = c + (p - c) * vec3(1.0, 1.2, 1.0);
    body = Sphere(squashP, c, 1.0);

    // 2. Hollow interior
    vec2 cavity = Sphere(squashP, c, 0.85);
    body.x = subtractionSDF(body.x, cavity.x);

    // 3. Triangular eyes
    vec2 leftEye = TriPrism(
        p,
        c + vec3(-0.35, 0.25, -0.85),
        vec2(0.4, 0.45),
        0.0
    );

    vec2 rightEye = TriPrism(
        p,
        c + vec3(0.35, 0.25, -0.85),
        vec2(0.4, 0.45),
        0.0
    );

    body.x = subtractionSDF(body.x, leftEye.x);
    body.x = subtractionSDF(body.x, rightEye.x);

    // 4. Triangular nose
    vec2 nose = TriPrism(
        p,
        c + vec3(0.0, -0.1, -0.9),
        vec2(0.2, 0.4),
        180.0
    );

    body.x = subtractionSDF(body.x, nose.x);

    // 5. Rectangular mouth
    vec2 mouth = RectPrism(
        p,
        c + vec3(0.0, -0.45, -0.85),
        vec3(0.55, 0.13, 0.5)
    );

    body.x = subtractionSDF(body.x, mouth.x);

    // 6. Stem
    vec2 stem = Cylinder(
        p,
        c + vec3(0.0, 0.9, 0.0),
        0.15,
        0.5,
        15.0
    );

    // 7. Combine stem and body
    float dist = unionSDF(body.x, stem.x);
    float id = getMaterial(body, stem);

    return vec2(dist, id);
}

	
float Fractal1(vec3 p0) {
    vec4 p = vec4(p0, 1.);

    for(int i = 0; i < 12; i++){
      p.xyz = mod(p.xyz-1.,2.)-1.;
      p*=1.4/dot(p.xyz,p.xyz);
    }

    return (length(p.xz/p.w)*0.25 * time * 0.1);
}

	
float Fractal2( vec3 pos ) {
    #define SCALE 2.8
    #define MINRAD2 .25 
    #define scale2 (vec4(SCALE, SCALE, SCALE, abs(SCALE)) / minRad2)
    float minRad2 = clamp(MINRAD2, 1.0e-9, 1.0);
    float absScalem1 = abs(SCALE - 1.0);
    float AbsScale = pow(abs(SCALE), float(1-10));
    vec4 p = vec4(pos,1);
    vec4 p0 = p;
    for (int i = 0; i < 9; i++)
    {
      p.xyz = clamp(p.xyz, -1.0, 1.0) * 2.0 - p.xyz;
      float r2 = dot(p.xyz, p.xyz);
      p *= clamp(max(minRad2/r2, minRad2), 0.0, 1.0);
      p = p*scale2 + p0;
    }
    return ((length(p.xyz) - absScalem1) / p.w - AbsScale);
}

	
// highly varied domain - take a look around
float Fractal3( vec3 p ){
    p = p.xzy;
    vec3 cSize = vec3(1., 1., 1.3);
    float scale = 3.;
    for( int i=0; i < 12; i++ ){
        p = 2.0*clamp(p, -cSize, cSize) - p;
        float r2 = dot(p,p);
        float k = max((2.)/(r2), .027);
        p *= k; scale *= k;
    }
    float l = length(p.xy);
    float rxy = l - 4.0;
    float n = l * p.z;
    rxy = max(rxy, -(n) / 4.);
    return (rxy) / abs(scale);
}

float sinSDF(vec3 p) {
    return sin(p.x) + sin(p.y) + sin(p.z);
}

	

float Fractal4(vec3 p) {
    float s = 2.0;
    float r2;

    p = abs(p);

    // Animate the folding strength
    float fold = 1.0 + 0.15 * sin(time);

    for (int i = 0; i < 12; i++) {
        p = fold - abs(p - fold);

        r2 = (i % 3 == 1)
            ? 1.3
            : 1.3 / max(dot(p, p), 0.0001);

        p *= r2;
        s *= r2;
    }

    return length(cross(p, normalize(vec3(1.0)))) / s - 0.003;
}

/*
 * Computes the signed distance to the closest surface in the scene.
 *
 * Parameters:
 *  - p: The point in 3D space to evaluate.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Signed distance to the closest material.
 *    - An identifier for the closest material type.
 */
vec2 getSceneDist(vec3 p) {
    
    // vec2 pumpkin = Pumpkin(p);
    // vec2 plane = Plane(p);
    
    // float dist = unionSDF(pumpkin.x, plane.x);
    // float id = getMaterial(pumpkin, plane);

    // return vec2(dist, id);
    vec3 p0 = p - (movement * 0.1);
    float f1 = Fractal1(p0);
    float f2 = Fractal2(p0);
    float f3 = Fractal3(p0);
    float f4 = Fractal4(p0);
    return vec2(f1, 4.0);
}

/*
 * Performs ray marching to determine the closest surface intersection.
 *
 * Parameters:
 *  - ro: Ray origin.
 *  - rd: Ray direction.
 *
 * Returns:
 *  - A vec2 containing:
 *    - Distance to the closest surface intersection.
 *    - material ID of the closest intersected surface.
 */
vec2 rayMarch(vec3 ro, vec3 rd) {
	float d = 0.;
	float id = 0.;
    
    /*
     * TODO: Implement the ray marching loop for MAX_STEPS.
     *       At each step, use getSceneDist to get the nearest surface distance.
     *       Update the distance and material ID based on the closest surface.
     *       Break if the distance is less than HIT_DIST or the travelled distance is greater than MAX_DIST.
     *       Note, if MAX_DIST is reached, the material ID should be 0.0 (background color).
     */
    for (int i = 0; i < MAX_STEPS; i++) {
        vec2 sceneDist = getSceneDist(ro + rd * d);
        float stepDist = sceneDist.x;
        d += stepDist;
        id = sceneDist.y;
        if (stepDist < HIT_DIST) {
            break;
        }
        if (d > MAX_DIST) {
            id = 0.0; // background color
            break;
        }

    }

    return vec2(d, id);
}

/* 
 * Helper: computes surface normal
 */
vec3 getNormal(vec3 p) {
	float d = getSceneDist(p).x;
    vec2 e = vec2(.01, 0);
    
    vec3 n = d - vec3(
        getSceneDist(p-e.xyy).x,
        getSceneDist(p-e.yxy).x,
        getSceneDist(p-e.yyx).x);

    return normalize(n);
}

vec3 fractalColor(vec3 p)
{
    vec3 q = p - PUMPKIN_CENTER;

    return vec3(
        0.5 + 0.5 * sin(q.x * 5.0),
        0.5 + 0.5 * sin(q.y * 5.0 + 2.0),
        0.5 + 0.5 * sin(q.z * 5.0 + 4.0)
    );
}
/*
 * Helper: gets surface color.
 */
vec3 getColor(vec3 p, float id) 
{
    vec3 lightPos1 = vec3(3, 5, 2); // sunset
    vec3 lightPos2 = vec3(0, 1.5, 5); // position candle (centre of pumpkin)

    vec3 l1 = normalize(lightPos1 - p); 
    vec3 l2 = normalize(lightPos2 - p); 
    
    vec3 n = getNormal(p);
    
    // Diffuse terms
    float diffuse1 = clamp(dot(n, l1), 0.2, 1.0);
    float diffuse2 = clamp(dot(n, l2), 0.2, 1.0);

    // Perform shadow check using ray marching 
    { 
        // NOTE: Comment out to improve render performance
        float d1 = rayMarch(p + n * HIT_DIST * 2., l1).x;
        if (d1 < length(lightPos1 - p)) diffuse1 *= 0.1;

        float d2 = rayMarch(p + n * HIT_DIST * 2., l2).x;
        if (d2 < length(lightPos2 - p)) diffuse2 *= 0.1;
    }

    vec3 diffuseColor;

    switch (int(id)) {
        case 0: // background color 
            // should not get here
            break;
        case 1: // grass colour
            diffuseColor = vec3(111,193,45);
            break;
        case 2: // pumpkin body colour
            diffuseColor = vec3(255,103,0);
            break;
        case 3: // stalk colour
            diffuseColor = vec3(136,68,34);
            break;
        case 4:
            diffuseColor = 255.0 * fractalColor(p);
            break;
        default: // background color 
            diffuseColor = vec3(255,147,0);
            break;
    }

    vec3 ambientColor = vec3(.9, .9, .9);
    float ambient = .1;
    
    vec3 lightColorSun = vec3(1.0, 0.55, 0.2);   // warm orange sunset
    vec3 lightColorCandle = vec3(1.0, 0.85, 0.6); // soft candlelight

    vec3 color = ambient * ambientColor
            + diffuse1 * lightColorSun * (diffuseColor / 255.0)
            + diffuse2 * lightColorCandle * (diffuseColor / 255.0);
    return color;
}

/*
 * Helper: camera matrix.
 */
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv =          ( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void main() {
    // Get the fragment coordinate in screen space
    vec2 fragCoord = gl_FragCoord.xy;
    
    // normalize to UV coordinates
    vec2 uv = (fragCoord - 0.5 * resolution.xy) / resolution.y;

    // NOTE: Look-at target (our pumpkin is centered here)
    // Camera target
    vec3 ta = PUMPKIN_CENTER;

    // Orbital angle controlled by A/D
    float angle = 0.2 * camPos.x;

    // Orbit around pumpkin
    vec3 ro = ta + vec3(
        5.0 * sin(angle),
        1.5,
        -5.0 * cos(angle)
    );

    // Camera orientation
    mat3 ca = setCamera(ro, ta, 0.0);

    // Ray direction
    vec3 rd = ca * normalize(vec3(uv.x, uv.y, 1.0));

    // Perform ray marching to find intersection distance and surface material ID
    vec2 dist = rayMarch(ro, rd); 
    float d = dist.x; 
    float id = dist.y; 

    // Surface intersection point
    vec3 p = ro + rd * d;

    // Compute surface color
    vec3 color;
    if (id == 0.0) {
        color = vec3(238,64,21) / 255.0; // background color
    } else {
        color = getColor(p, id);
    }

    // Apply gamma correction to adjust brightness (convert from linear to sRGB space)
    color = pow(color, vec3(0.4545)); 

    // Output the final color to the fragment shader
    gl_FragColor = vec4(color, 1.0); 
}
