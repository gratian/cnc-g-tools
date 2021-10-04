/*
  SPDX-License-Identifier: MIT
  Copyright © 2021 Gratian Crisan. All Rights Reserved.
*/
#ifndef _AXES_H_
#define _AXES_H_

struct axes {
	/* translational axes */
	double x;	/* left to right */
	double y;	/* front to back */
	double z;	/* up and down */

	/* rotational axes */
	double a;	/* rotation around X axis */
	double b;	/* rotation around Y axis */
	double c;	/* rotation around Z axis */

	/* incremental axes, mostly for lathes */
	double u;	/* incremental axis for X axis */
	double v;	/* incremental axis for Y axis */
	double w;	/* incremental axis for Z axis */

	/* G02 and G03 arc commands (or parameter for some fixed cycles) */
	double i;	/* arc center in X axis relative to current possition */
	double j;	/* arc center in Y axisr elative to current possition */
	double k;	/* arc center in Y axisr elative to current possition */
};

#endif /* _AXES_H_ */
