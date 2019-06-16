# Documentation

## Designing levels in Blender:
Custom parameters to add to object names so that the import script will set up everything nicely.

### Level Structure in Godot (auto generated with import script):
* Attractor Mesh (Gets Area signals)
  - Static collision body (Collider for atttractor mesh)
    - Shape
  - Gravity influence area
    - Shape
  - Gravity definition (Simply a node that has a method to return the gravity direction)
    - Linear (Single direction)
    - Radial (Attract or repel point)
    - Cylindrical (Attract or repel line)
    - Curve (Attract or repel curve) (Not implemented yet... )
    - Surface (Based on mesh surface)

### Blender structure:
Add `-param` to blender object names.

#### In general for any given attractor:
* mesh `-attract` `-convcol/col`
  - mesh/empty `-grav_area`
  - mesh/empty `-grav_definition` `-linear/radial(!)/cylinder(!)/surface`

#### Attractor parameters:
Object is a mesh that defines the shape of the attractor.
Make sure `-attract` is in the object name.
`-convcol/col` are the usual Godot physics parameters for convex and concave static bodies.

#### Gravity area parameters:
Mesh will define a *convex* area in which to apply gravity, concave don't work.
Empty will define a spherical area in which to apply gravity based on scale (*Do Not Apply Scale!*).

#### Gravity definition parameters:
Mesh object is needed for a surface definition.

##### Linear:
Use a single arrow empty object, the rotation defines the gravity direction.
Use `-linear` parameter.

##### Radial:
Use an empty object, position defines the point to attract to or repel from.
Use `-radial` to attract and `-radial!` to repel.

##### Cylinder:
Use a circle empty object to define a point and a rotation, which together describe the line to attract to or repel from.
Use `-cylinder` to attract and `-cylinder!` to repel.

##### Surface:
Use a mesh to define the surface to attract to.
Use `-surface` parameter.
