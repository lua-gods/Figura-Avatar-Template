A code ready Figura Avatar template

this is the template GN personally use for all his Avatars, its a perfect balance of simplicity and organization

## Layout

### CORE
- automatically loaded before **auto** does
- the only difference is that returning true will stop the Avatar from running entirely
- this folder is where you should put scripts that patches the overall environment of the Avatar
### AUTO
- automatically loaded when the Avatar initializes
- where your avatar specific scripts should go.
### LIB
- not loaded automatically, this is where you put your libraries at for organization, and simply require into this folder.
- its not required automatically to avoid initializing scripts that arent gonna be used, do note that they still take storage.

## Notes
- to avoid using too many init instructions and loading unused scripts, only the `main.lua` file is triggered at initialization.
- Lua Language Server hinting is disabled to clear up space on the editor, simply hover over the variable to get its type instead.

last updated for: Figura 0.1.6