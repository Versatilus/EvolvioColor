class Tile {
	public final double[] barrenColor = { 0, 0, 1. };
	public final double[] fertileColor = { 0, 0, 0.2 };
	public final double[] blackColor = { 0, 1., 0 };
	public final color waterColor = color(0, 0, 0);
	public final float FOOD_GROWTH_RATE = .25;
	private double fertility;
	private double foodLevel;
	private final float maxGrowthLevel = 1.0;
	private int posX;
	private int posY;
	public double lastUpdateTime = 0;
	public double climateType;
	public double foodType;
	Board board;

	public Tile(int x, int y, double f, float food, float type, Board b) {
		posX = x;
		posY = y;
		fertility = Math.max(0, f);
		foodLevel = Math.max(0, food);
		climateType = foodType = type;
		board = b;
	}

	public double getFertility() {
		return fertility;
	}
	public double getFoodLevel() {
		return foodLevel;
	}
	public void setFertility(double f) {
		fertility = f;
	}
	public void setFoodLevel(double f) {
		foodLevel = f;
	}
	public void drawTile(float scaleUp, boolean showEnergy) {
		stroke(0, 0, 0, 1);
		strokeWeight(.75);

		color landColor = getColor();

		fill(landColor);
		rect(posX * scaleUp, posY * scaleUp, scaleUp, scaleUp);
		if (showEnergy && getCurrentLOD() >= LOD_TEXT) {
			iterate();
			if (brightness(landColor) >= 0.7)
				fill(0, 0, 0, 1);
			else
				fill(0, 0, 1, 1);
			textAlign(CENTER);
			textFont(font, 21);
			text(nf((float)(100 * foodLevel), 0, 2) + " yums", (posX + 0.5) * scaleUp, (posY + 0.3) *
			scaleUp);
			text("Clim: " + nf((float)(climateType), 0, 2), (posX + 0.5) * scaleUp, (posY + 0.6) *
			scaleUp);
			text("Food: " + nf((float)(foodType), 0, 2), (posX + 0.5) * scaleUp, (posY + 0.9) * scaleUp);
		}
	}
	public void iterate() {
		double updateTime = board.year;


		if (Math.abs(lastUpdateTime - updateTime) >= 0.00001) {
			double growthChange = board.getGrowthOverTimeRange(lastUpdateTime, updateTime);

			if (fertility > 1) {              // This means the tile is water.
				foodLevel = 0;
			} else {
				if (growthChange > 0) {         // Food is growing. Exponentially approach maxGrowthLevel.
					if (foodLevel < maxGrowthLevel) {
						double newDistToMax = (maxGrowthLevel - foodLevel) * Math.pow(2.71828182846,
							-growthChange * fertility * FOOD_GROWTH_RATE);
						double foodGrowthAmount = (maxGrowthLevel - newDistToMax) - foodLevel;

						addFood(foodGrowthAmount, climateType, false);
					}
				} else {                        // Food is dying off. Exponentially approach 0.
					removeFood(foodLevel - foodLevel * Math.pow(2.71828182846, growthChange *
					FOOD_GROWTH_RATE), false);
				}
				/*if(growableTime > 0){
				 * if(foodLevel < maxGrowthLevel){
				 *  double foodGrowthAmount = (maxGrowthLevel-foodLevel)*fertility*FOOD_GROWTH_RATE*timeStep*growableTime;
				 *  addFood(foodGrowthAmount,climateType);
				 * }
				 * }else{
				 * foodLevel += maxGrowthLevel*foodLevel*FOOD_GROWTH_RATE*timeStep*growableTime;
				 * }*/
				// }
			}
			foodLevel = Math.max(foodLevel, 0);
			lastUpdateTime = updateTime;
		}
	}
	public void addFood(double amount, double addedFoodType, boolean canCauseIteration) {
		if (canCauseIteration)
			iterate();
		foodLevel += amount;

		/*if(foodLevel > 0){
		 * foodType += (addedFoodType-foodType)*(amount/foodLevel); // We're adding new plant growth, so we gotta "mix" the colors of the tile.
		 * }*/
	}
	public void removeFood(double amount, boolean canCauseIteration) {
		if (canCauseIteration)
			iterate();
		foodLevel -= amount;
	}
	public color getColor() {
		iterate();
		double[] foodColor = { foodType, 1, 1 };
		if (fertility > 1) {
			return waterColor;
		} else if (foodLevel < maxGrowthLevel) {
			return interColorFixedHue(interColor(barrenColor, fertileColor, fertility), foodColor,
				foodLevel / maxGrowthLevel, foodColor[0]);
		} else {
			return interColorFixedHue(foodColor, blackColor, 1.0 - maxGrowthLevel / foodLevel,
				foodColor[0]);
		}
	}
	public double[] interColor(double[] a, double[] b, double x) {
		return new double[] {
						 a[0] + (b[0] - a[0]) * x, a[1] + (b[1] - a[1]) * x, a[2] + (b[2] - a[2]) * x
		};
	}
	public color interColorFixedHue(double[] a, double[] b, double x, double hue) {
		double satB = b[1];


		if (b[2] == 0)                      // I want black to be calculated as 100% saturation
			satB = 1;

		double sat = a[1] + (satB - a[1]) * x;
		double bri = a[2] + (b[2] - a[2]) * x;

		return color((float)(hue), (float)(sat), (float)(bri));
	}
}
