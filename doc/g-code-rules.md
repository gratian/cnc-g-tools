##Line rules

###Item repeats

  - A line may have any number of G words.

  - Two G words from the same modal group may not appear on the same
    line.

  - A line may have zero to four M words.

  - Two M words from the same modal group may not appear on the same
    line.

  - All other legal letters can appear only once on the same line.

  - If a parameter setting is repeated, only the last setting will
    take effect.

###Item order

  There are three types of items whose order may vary on a line: word,
  parameter setting, and comment.

  - Words can be reorder in any way without changing the meaning of
    the line.

  - If parameters are re-ordered there's no change in meaning unless a
    parameter is set more than once. In that case only the last
    setting will take effect. Writting parameters takes effect after
    all the parameter reads on the line.

  - It is  an error to  put a  G-code from group  1 and a  G-code from
    group 0 (non-modal group) on the same line if both use axis words.
    If an axis word-using G-code from  group 1 is implicitly in effect
    on a  line (by  having been  activate on an  earlier line),  and a
    group  0 G-code  that uses  axis words  appears on  the line,  the
    activity of  group 1 G-code is  suspended for that line.  The axis
    word-using G-codes from group 0 are: G10, G28, G30, and G92.

* Axes:* A, B, C, U, V, W, X, Y, Z.

### Order of execution

  * The expressions on a line are evaluated when the line is read, before anything on the line is executed.

  * A parameter setting does not take effect until after all parameter values on the same line have been found.

0.  O-word commands (optionally followed by a comment but no other words allowed on the same line)
1.  Comment (including message)
2.  Set feed rate mode (G93, G94). [gratian: G96, G97]
3.  Set feed rate (F).
4.  Set spindle speed (S).
5.  Select tool (T).
6.  HAL pin I/O (M62-M68).
7.  Change tool (M6) and Set Tool Number (M61).
8.  Spindle on or off (M3, M4, M5).
9.  Save State (M70, M73), Restore State (M72), Invalidate State (M71).
10. Coolant on or off (M7, M8, M9).
11. Enable or disable overrides (M48, M49, M50, M51, M52, M53).
12. User-defined Commands (M100-M199).
13. Dwell (G4).
14. Set active plane (G17, G18, G19).
15. Set length units (G20, G21).
16. Cutter radius compensation on or off (G40, G41, G42)
17. Cutter length compensation on or off (G43, G49)
18. Coordinate system selection (G54, G55, G56, G57, G58, G59, G59.1, G59.2, G59.3).
19. Set path control mode (G61, G61.1, G64)
20. Set distance mode (G90, G91). [gratian: G7, G8]
21. Set retract mode (G98, G99).
22. Go to reference location (G28, G30) or change coordinate system data (G10) or set axis offsets (G92, G92.1, G92.2, G92.3).
23. Perform motion (G0 to G3, G33, G38.n, G73, G76, G80 to G89), as modified (possibly) by G53.
24. Stop (M0, M1, M2, M30, M60).
