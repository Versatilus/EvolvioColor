final double MUTABILITY_MUTABILITY = 0.7;
final int mutatePower = 5;

class Axon {
	double MUTATE_MULTI;
	double weight;
	double mutability;

	public Axon(double w, double m) {
		weight = w;
		mutability = m;
		MUTATE_MULTI = Math.pow(0.5, mutatePower);
	}
	public Axon mutateAxon() {
		double mutabilityMutate = Math.pow(0.5, pmRan() * MUTABILITY_MUTABILITY);


		return new Axon(weight + r() * mutability / MUTATE_MULTI, mutability * mutabilityMutate);
	}
	public double r() {
		return Math.pow(ThreadLocalRandom.current().nextGaussian() * .33333, mutatePower);
	}
	public double pmRan() {
		return ThreadLocalRandom.current().nextDouble() * 2.0 - 1.0;
	}
}
