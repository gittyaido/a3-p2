uniform vec3 spherePosition;

// A shared variable is initialized in the vertex shader and attached to the current vertex being processed,
// such that each vertex is given a shared variable and when passed to the fragment shader,
// these values are interpolated between vertices and across fragments,
// below we can see the shared variable is initialized in the vertex shader using the 'out' classifier
out vec3 viewPosition;
out vec3 worldPosition;
out vec3 interpolatedNormal;

void main() {
    
    // TODO: compute the out variables declared above. Think about which frame(s) each
    // variable should be defined with respect to
    vec4 worldPos = modelMatrix * vec4(position, 1.0);
    vec4 viewPos = viewMatrix * worldPos;

    worldPosition = worldPos.xyz;
    viewPosition = viewPos.xyz;

    interpolatedNormal = normalize(normalMatrix * normal);

    gl_Position = projectionMatrix * viewPos;
}
