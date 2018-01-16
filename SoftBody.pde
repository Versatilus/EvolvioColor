class SoftBody {
	double px;
	double py;
	double vx;
	double vy;
	double energy;
	float ENERGY_DENSITY;                 // set so when a creature is of minimum size, it equals one.
	double density;
	double hue;
	double saturation;
	double brightness;
	double birthTime;
	boolean isCreature = false;
	final float FRICTION = 0.004;
	final float COLLISION_FORCE = 0.025;
	final float FIGHT_RANGE = 3.0;
	double fightLevel = 0;
	int SBIPMinX;
	int SBIPMinY;
	int SBIPMaxX;
	int SBIPMaxY;
	double numberOfCollisions = 0.;

	CopyOnWriteArrayList<SoftBody> colliders;

	Board board;

	public SoftBody(double tpx, double tpy, double tvx, double tvy, double tenergy, double tdensity,
	double thue, double tsaturation, double tbrightness, Board tb, double bt) {
		px = tpx;
		py = tpy;
		vx = tvx;
		vy = tvy;
		energy = tenergy;
		density = tdensity;
		hue = thue;
		saturation = tsaturation;
		brightness = tbrightness;
		board = tb;
		setSBIP();
		birthTime = bt;
		ENERGY_DENSITY = 1.0 / (tb.MINIMUM_SURVIVABLE_SIZE * tb.MINIMUM_SURVIVABLE_SIZE * PI);
	}

	public synchronized void setSBIP() {
		double radius = getRadius() * FIGHT_RANGE;


		SBIPMinY = yBound((int)(Math.floor(py - radius)));
		SBIPMinX = xBound((int)(Math.floor(px - radius)));
		SBIPMaxX = xBound((int)(Math.floor(px + radius)));
		SBIPMaxY = yBound((int)(Math.floor(py + radius)));
		for (int x = SBIPMinX; x <= SBIPMaxX; x++) {
			for (int y = SBIPMinY; y <= SBIPMaxY; y++)
				board.addSoftBodiesInPositions(x, y, this);
		}
	}
	public synchronized ArrayList[][] updateSBIP() {
		ArrayList[][] scratch = new ArrayList[board.boardWidth][board.boardHeight];
		for (int x = 0; x < board.boardWidth; x++) {
			for (int y = 0; y < board.boardHeight; y++)
				scratch[x][y] = new ArrayList<SoftBody>();
		}

		double radius = getRadius() * FIGHT_RANGE;

		SBIPMinX = xBound((int)(Math.floor(px - radius)));
		SBIPMinY = yBound((int)(Math.floor(py - radius)));
		SBIPMaxX = xBound((int)(Math.floor(px + radius)));
		SBIPMaxY = yBound((int)(Math.floor(py + radius)));
		for (int x = SBIPMinX; x <= SBIPMaxX; x++) {
			for (int y = SBIPMinY; y <= SBIPMaxY; y++)
				scratch[x][y].add(this);
		}
		return scratch;
	}
	public int xBound(int x) {
		return Math.min(Math.max(x, 0), board.boardWidth - 1);
	}
	public int yBound(int y) {
		return Math.min(Math.max(y, 0), board.boardHeight - 1);
	}
	public double xBodyBound(double x) {
		double radius = getRadius();


		return Math.min(Math.max(x, radius), board.boardWidth - radius);
	}
	public double yBodyBound(double y) {
		double radius = getRadius();


		return Math.min(Math.max(y, radius), board.boardHeight - radius);
	}
	public void collide(double timeStep) {
		double oldNumberOfCollisions = numberOfCollisions;


		ArrayList<SoftBody> scratch = new ArrayList<SoftBody>();
		for (int x = SBIPMinX; x <= SBIPMaxX; x++) {
			for (int y = SBIPMinY; y <= SBIPMaxY; y++) {
				for (SoftBody newCollider : board.getSoftBodiesInPositions(x, y)) {
					if (!scratch.contains(newCollider) && newCollider != this)
						scratch.add(newCollider);
				}
			}
		}
		colliders = new CopyOnWriteArrayList<SoftBody>(scratch);
		for (SoftBody collider : colliders) {
			float distance = dist((float)px, (float)py, (float)collider.px, (float)collider.py);
			double combinedRadius = getRadius() + collider.getRadius();

			if (distance < combinedRadius) {
				numberOfCollisions = (numberOfCollisions + 2.) / 3.;

				double force = combinedRadius * COLLISION_FORCE;

				vx += ((px - collider.px) / distance) * force / getMass();
				vy += ((py - collider.py) / distance) * force / getMass();
			}
		}
		if (oldNumberOfCollisions == numberOfCollisions)
			numberOfCollisions *= .975;
		fightLevel = 0;
	}
	public void applyMotions(double timeStep) {
		px = xBodyBound(px + vx * timeStep);
		py = yBodyBound(py + vy * timeStep);
		vx *= Math.max(0, 1 - FRICTION / getMass());
		vy *= Math.max(0, 1 - FRICTION / getMass());
	}
	public void drawSoftBody(float scaleUp) {
		if (getCurrentLOD() >= LOD_BODY) {
			double radius = getRadius();


			stroke(0);
			strokeWeight(board.CREATURE_STROKE_WEIGHT);
			fill((float)hue, (float)saturation, (float)brightness);
			ellipseMode(RADIUS);
			ellipse((float)(px * scaleUp), (float)(py * scaleUp), (float)(radius * scaleUp),
			(float)(radius * scaleUp));
		}
	}
	public double getRadius() {
		if (energy <= 0)
			return 0;
		else
			return Math.sqrt(energy / ENERGY_DENSITY / Math.PI);
	}
	public double getMass() {
		return energy / ENERGY_DENSITY * density;
	}
}
