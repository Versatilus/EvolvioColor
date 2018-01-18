/*
 * Copyright (c) 2010, 2013, Oracle and/or its affiliates. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 *   - Neither the name of Oracle or the names of its
 *     contributors may be used to endorse or promote products derived
 *     from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 * IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
// import evolvioColor;
import java.util.concurrent.ForkJoinPool;
import java.util.concurrent.RecursiveAction;


/**
 * ForkBlur implements a simple horizontal image blur. It averages pixels in the
 * source array and writes them to a destination array. The sThreshold value
 * determines whether the blurring will be performed directly or split into two
 * tasks.
 *
 * This is not the recommended way to blur images; it is only intended to
 * illustrate the use of the Fork/Join framework.
 */
public class NetworkRunner extends RecursiveAction {
	private EvolvioColor.Creature[] creatures;
	private int mStart;
	private int mLength;
	private double timeStep;
	private int sThreshold = 5;

	public NetworkRunner(EvolvioColor.Creature[] workgroup, int start, int length, double ts) {
		creatures = workgroup;
		mStart = start;
		mLength = length;
		timeStep = ts;


		int processors = Runtime.getRuntime().availableProcessors();

		sThreshold = creatures.length / (int)(processors * 2.5) > 5 ? creatures.length / (int)(2.5 *
		processors) : 5;
	}

	protected void computeDirectly() {
		for (int index = mStart; index < mStart + mLength; index++) {
			creatures[index].averageEnergy = creatures[index].updateAndAverageStat(
				creatures[index].previousEnergy, creatures[index].energy, creatures[index].averageEnergy);
			creatures[index].averageAcceleration = creatures[index].updateAndAverageStat(
				creatures[index].previousAcceleration, creatures[index].accelerationDesire,
				creatures[index].averageAcceleration);
			creatures[index].averageTurning = creatures[index].updateAndAverageStat(
				creatures[index].previousTurning, creatures[index].rotationDesire,
				creatures[index].averageTurning);
			creatures[index].averageEating = creatures[index].updateAndAverageStat(
				creatures[index].previousEating, creatures[index].foodDesire,
				creatures[index].averageEating);
			creatures[index].averageFighting = creatures[index].updateAndAverageStat(
				creatures[index].previousFighting, creatures[index].fightDesire,
				creatures[index].averageFighting);

			creatures[index].collide(timeStep);
			creatures[index].metabolize(timeStep);
			creatures[index].parseInputs(timeStep);

			creatures[index].useBrain(timeStep);
		}
	}
	@Override
	protected void compute() {
		if (mLength < sThreshold) {
			computeDirectly();
			return;
		}

		int split = mLength / 2;

		invokeAll(new NetworkRunner(creatures, mStart, split, timeStep), new NetworkRunner(creatures,
		mStart + split, mLength - split, timeStep));
	}
}

//// Plumbing follows.
// public static void main(String[] args) throws Exception {
// String srcName = "red-tulips.jpg";
// File srcFile = new File(srcName);
// BufferedImage image = ImageIO.read(srcFile);
//
// System.out.println("Source image: " + srcName);
//
// BufferedImage blurredImage = blur(image);
//
// String dstName = "blurred-tulips.jpg";
// File dstFile = new File(dstName);
// ImageIO.write(blurredImage, "jpg", dstFile);
//
// System.out.println("Output image: " + dstName);
//
// }
//
// public static void updateNetworks(ArrayList<Creature>) {
// int w = srcImage.getWidth();
// int h = srcImage.getHeight();
//
// int[] src = srcImage.getRGB(0, 0, w, h, null, 0, w);
// int[] dst = new int[src.length];
//
// System.out.println("Array size is " + src.length);
// System.out.println("Threshold is " + sThreshold);
//
// int processors = Runticreatures[index].getRuntime().availableProcessors();
// System.out.println(Integer.toString(processors) + " processor"
// + (processors != 1 ? "s are " : " is ")
// + "available");
//
// ForkBlur fb = new ForkBlur(src, 0, src.length, dst);
//
// ForkJoinPool pool = new ForkJoinPool();
//
// long startTime = System.currentTimeMillis();
// pool.invoke(fb);
// long endTime = System.currentTimeMillis();
//
// System.out.println("Image blur took " + (endTime - startTime) +
// " milliseconds.");
//
// BufferedImage dstImage =
// new BufferedImage(w, h, BufferedImage.TYPE_INT_ARGB);
// dstImage.setRGB(0, 0, w, h, dst, 0, w);
//
// return dstImage;
// }
// }
