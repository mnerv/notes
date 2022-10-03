# OpenGL C++ Snippets

## macOS

macOS related settings for OpenGL.

### Set the version to 4.1

OpenGL 4.1 is the latest version macOS still has.

For `GLFW` use the following code to set it.

```
glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 4);
glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 1);
glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
```

For `SDL`.

```
SDL_GL_LoadLibrary(nullptr);
SDL_GL_SetAttribute(SDL_GL_ACCELERATED_VISUAL, true);
// Set OpenGL 4.1
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 4);
SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 1);

SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
SDL_GL_SetAttribute(SDL_GL_CONTEXT_FLAGS, SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG);
```

