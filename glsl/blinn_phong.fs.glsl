
uniform vec3 ambientColor;
uniform float kAmbient;

uniform vec3 diffuseColor;
uniform float kDiffuse;

uniform vec3 specularColor;
uniform float kSpecular;
uniform float shininess;

uniform mat4 modelMatrix;

uniform vec3 spherePosition;

// The value of our shared variable is given as the interpolation between normals computed in the vertex shader
// below we can see the shared variable we passed from the vertex shader using the 'in' classifier
in vec3 interpolatedNormal;
in vec3 viewPosition;
in vec3 worldPosition;


void main() {
    // TODO:
    // HINT: compute the following - light direction, ambient + diffuse + specular component,
    // then set the final color as a combination of these components
    vec3 lightDirection = normalize(spherePosition - worldPosition);
    vec3 normal = normalize(interpolatedNormal);

    vec3 diffuse = max(dot(lightDirection, normal), 0.0) * kDiffuse * diffuseColor;
    vec3 ambient = ambientColor * kAmbient;
    
    // vec3 camPos = ;
    vec3 viewDirection = normalize(cameraPosition - worldPosition);
    vec3 halfDir = normalize(lightDirection + viewDirection);
    float shine = pow(max(dot(halfDir, normal), 0.0), shininess);
    vec3 specular = specularColor * kSpecular * shine;
    
    vec3 frag = ambient + diffuse + specular;
    gl_FragColor = vec4(frag, 1.0);
}
