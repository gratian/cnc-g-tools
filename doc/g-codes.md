# G Code Quick Reference Table

Code 	Description
-------------------------------------------------------
G0 - Coordinated Motion at Rapid Rate
G1 - Coordinated Motion at Feed Rate
G2 G3 - Coordinated Helical Motion at Feed Rate
G4 - Dwell
G5 - Cubic Spline
G5.1 - Quadratic B-Spline
G5.2 - NURBS, add control point
G7 - Diameter Mode (lathe)
G8 - Radius Mode (lathe)
G10 L1 - Set Tool Table Entry
G10 L10 - Set Tool Table, Calculated, Workpiece
G10 L11 - Set Tool Table, Calculated, Fixture
G10 L2 - Coordinate System Origin Setting
G10 L20 - Coordinate System Origin Setting Calculated
G17 - G19.1 - Plane Select
G20 G21 - Set Units of Measure
G28 - G28.1 - Go to Predefined Position
G30 - G30.1 - Go to Predefined Position
G33 - Spindle Synchronized Motion
G33.1 - Rigid Tapping
G38.2 - G38.5 - Probing
G40 - Cancel Cutter Compensation
G41 G42 - Cutter Compensation
G41.1 G42.1 - Dynamic Cutter Compensation
G43 - Use Tool Length Offset from Tool Table
G43.1 - Dynamic Tool Length Offset
G43.2 - Apply additional Tool Length Offset
G49 - Cancel Tool Length Offset
G53 - Move in Machine Coordinates
G54-G59.3 - Select Coordinate System (1 - 9)
G61 G61.1 - Path Control Mode
G64 - Path Control Mode with Optional Tolerance
G73 - Drilling Cycle with Chip Breaking
G76 - Multi-pass Threading Cycle (Lathe)
G80 - Cancel Motion Modes
G81 - Drilling Cycle
G82 - Drilling Cycle with Dwell
G83 - Drilling Cycle with Peck
G85 - Boring Cycle, No Dwell, Feed Out
G86 - Boring Cycle, Stop, Rapid Out
G89 - Boring Cycle, Dwell, Feed Out
G90 G91 - Distance Mode
G90.1 G91.1 - Arc Distance Mode
G92 - Coordinate System Offset
G92.1 G92.2 - Cancel G92 Offsets
G92.3 - Restore G92 Offsets
G93 G94 G95 - Feed Modes
G96 - Spindle Control Mode
G98 G99 - Canned Cycle Z Retract Mode
