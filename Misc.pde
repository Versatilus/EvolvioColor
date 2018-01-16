public double inter(double a, double b, double x) {
	return a + (b - a) * x;
}

public int xBound(int x) {
	return Math.min(Math.max(x, 0), BOARD_WIDTH - 1);
}

public int yBound(int y) {
	return Math.min(Math.max(y, 0), BOARD_HEIGHT - 1);
}

public double distance(double x1, double y1, double x2, double y2) {
	return Math.sqrt((x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1));
}
