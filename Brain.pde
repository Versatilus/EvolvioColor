final int BRAIN_WIDTH = 6;
final double AXON_START_MUTABILITY = 0.00375;
final double STARTING_AXON_VARIABILITY = 1.0;
int BRAIN_HEIGHT = 20;

String[] inputLabels = { "CHue", "CSat", "CBri", "LHue", "LSat", "LBri", "RHue", "RSat", "RBri",
	                       "LVisD", "RVisD",                              // "Accel.", "Turn", "Eat", "Fight",
	                       "EnergyD", "Size", "Sine Rot.", "Cosine Rot.", "UniRand", "NormRand",
	                       "Season", "# of Coll.", "Const." };
String[] outputLabels = { "Accel.", "Turn", "Eat", "Fight", "Birth" };  // , "MHue", "BHue", "MHue2","BHue2" };


Axon[][][] newWeights(int[] _shape) {
	double variance = 1.0/(Math.sqrt(BRAIN_HEIGHT));
	Axon[][][] weights = new Axon[_shape[0]][_shape[1]][_shape[2]];
	for (int x = 0; x < weights.length; x++) {
		for (int y = 0; y < weights[x].length; y++) {
			for (int z = 0; z < weights[x][y].length; z++) {
				// double startingWeight = Math.pow((Math.random() * 4. - 2.), mutatePower) *
				// AXON_START_MUTABILITY / Math.pow(0.5, mutatePower);
				double startingWeight = ThreadLocalRandom.current().nextGaussian() * variance;

				// if (y == weights[x].length - 1)
				// startingWeight = Math.copySign(ThreadLocalRandom.current().nextGaussian() * 1.5 + .5,
				// ThreadLocalRandom.current().nextDouble() * 2 - 1);
				weights[x][y][z] = new Axon(startingWeight * STARTING_AXON_VARIABILITY,
					AXON_START_MUTABILITY);
			}
		}
	}
	return weights;
}

Axon[][] newMemoryWeights(int[] _shape) {
	double variance = 1.0/(Math.sqrt(BRAIN_HEIGHT*2));
	Axon[][] weights = new Axon[_shape[0]][_shape[1]];
	for (int x = 0; x < weights.length; x++) {
		for (int y = 0; y < weights[x].length; y++) {
			double startingWeight = ThreadLocalRandom.current().nextGaussian() * variance;

			weights[x][y] = new Axon(startingWeight * STARTING_AXON_VARIABILITY, AXON_START_MUTABILITY);
		}
	}
	return weights;
}

double[][] newActivations(int[] _shape) {
	double[][] activations = new double[_shape[0]][_shape[1]];
	for (int x = 0; x < activations.length; x++) {
		for (int y = 0; y < activations[x].length; y++) {
			if (y == activations[x].length - 1)
				activations[x][y] = ThreadLocalRandom.current().nextGaussian();

			/*Math.copySign(ThreadLocalRandom.current().nextDouble() * 1.5 + .25,
			 * ThreadLocalRandom.current().nextDouble() * 2 - 1);*/
			else
				activations[x][y] = 0;
		}
	}
	return activations;
}

Axon[][][] offspringWeights(ArrayList<Creature> parents, Axon[][][] prototypeWeights) {
	Axon[][][] weights =
	new Axon[prototypeWeights.length][prototypeWeights[0].length][prototypeWeights[0][0].length];

	double randomParentRotation = ThreadLocalRandom.current().nextDouble();

	for (int x = 0; x < prototypeWeights.length; x++) {
		for (int y = 0; y < prototypeWeights[x].length; y++) {
			for (int z = 0; z < prototypeWeights[x][y].length; z++) {
				float axonAngle = atan2((y + z) / 2.0 - prototypeWeights[x][y].length / 2.0, x -
					prototypeWeights.length / 2.) / (TAU) + PI;
				Creature parentForAxon = parents.get((int)(((axonAngle + randomParentRotation) % 1.0) *
					parents.size()));

				weights[x][y][z] = parentForAxon.axons[x][y][z].mutateAxon();
			}
		}
	}
	return weights;
}

Axon[][] offspringMemoryWeights(ArrayList<Creature> parents, Axon[][] prototypeWeights) {
	Axon[][] weights = new Axon[prototypeWeights.length][prototypeWeights[0].length];

	double randomParentRotation = ThreadLocalRandom.current().nextDouble();

	for (int x = 0; x < prototypeWeights.length; x++) {
		for (int y = 0; y < prototypeWeights[x].length; y++) {
			float axonAngle = atan2((y + x) / 2.0 - prototypeWeights[x].length / 2.0, x -
				prototypeWeights.length / 2.) / (TAU) + PI;
			Creature parentForAxon = parents.get((int)(((axonAngle + randomParentRotation) % 1.0) *
				parents.size()));

			weights[x][y] = parentForAxon.memoryAxons[x][y].mutateAxon();
		}
	}
	return weights;
}

double[][] offspringActivations(ArrayList<Creature> parents) {
	double[][] prototypeActivations = parents.get(0).neurons;
	double[][] activations = new double[prototypeActivations.length][prototypeActivations[0].length];

	double randomParentRotation = ThreadLocalRandom.current().nextDouble();

	for (int x = 0; x < prototypeActivations.length; x++) {
		for (int y = 0; y < prototypeActivations[x].length; y++) {
			float axonAngle = atan2(y - prototypeActivations[x].length / 2.0, x -
				prototypeActivations.length / 2.) / (TAU) + PI;
			Creature parentForAxon = parents.get((int)(((axonAngle + randomParentRotation) % 1.0) *
				parents.size()));

			if (y == prototypeActivations[x].length - 1)
				activations[x][y] = parentForAxon.neurons[x][y] * .95;
			else
				activations[x][y] = parentForAxon.neurons[x][y];
		}
	}
	return activations;
}

class Brain {
	Network neuralnetwork;

	Brain(int[] _shape) {
		neuralnetwork = new Network(_shape);
	}
}
