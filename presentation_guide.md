One of the most powerful tools in image processing is a kernel. It helps implement edge detection, but it can also be used for other filters like blurring and sharpening. 

Kernels are small masks that can be applied to a pixel in an image in order to get an output pixel. This output pixel is a combination of the pixel itself and the surrounding “neighborhood” pixels. The kernel specifies the size of this neighborhood and how to actually combine the pixels in this “neighborhood” together. 

The kernel itself is a small matrix, and in code a 2D array. Kernels are always square, meaning the matrix has the same number of rows as columns, and odd, meaning the rows/columns are odd. Each value in the kernel specifies a scalar for a pixel in the image. The size of the matrix and the values inside is how a kernel specifies a “neighborhood” size and how to combine them together. 

When applying a kernel to a pixel, it is centered on that pixel (this is why it must be odd, so there is a singular pixel in the center) it extends up and down  ½ the side length number of pixels, as well as left and right ½ the side length number of pixels. Each pixel is mapped to its spot on the kernel and multiplied by the kernel value. The sum of these multiplications is calculated and converted into the output color for the input pixel. 

A common mistake for this is to use the same array of pixels and update that array for each kernel multiplication, as this will change the value of that pixel, thus messing up every calculation thereafter. Calculated pixels need to be stored in another image. 

After this, you may need to do what is called “normalizing the values”. This concept is extremely simple, and it is based on the fact that if you add the RGB values of all of the points surrounding it, it could have a value greater than the 0-255 range for RGB values. The most this value can go up to is 255 * (the number of pixels that are considered by the kernel). Therefore, we normalize the value by dividing by the number of pixels considered by the kernel. Commonly, if you search for different types of kernels, you will see a fraction in front of the kernel, which is what is used to represent this normalization process. 

By the way, one of the biggest issues we went through was just trying to understand the math behind many of these concepts. We understood kernels, at least I believe, decently well, but there are other more complicated concepts like the one used behind contours that required much more math than we could understand. 

Often, we found that the opencv docs did well in explaining how to use the code in an actual program, but failed to truly explain the concepts behind the things each line of code was doing, meaning it was hard for us to understand exactly what could be changed and what couldn’t. In addition, usually reliable resources like wikipedia weren’t any help because they were often too technical. 

Ok, I am going to talk to you guys about the OpenCV Edge finder, OpenCV background subtraction, and OpenCV image filters. For our Edge detectors, we have a dropdown which allows you to choose the type of filter which is going to be applied to detect the edges. 

Let me first talk to you about the simplest concept: global thresholding. If you see in our list of BRC Controls, under image filters, there is something called threshold, with an accompanying slider. This filter will basically check to see if the grayscale value of a pixel is greater than or less than a preset threshold. If it is greater, then it will set that value to be black, otherwise it will set it to white.The idea of applying a constant threshold to an entire image is what we consider global thresholding.

Adaptive Thresholding, which is labeled as adaptive on our BRC controls, changes the threshold value based on a few conditions. This can be useful in circumstances where you may need to change the threshold, like when reading text which isn’t flat. Because of the different angles and different amounts of light, your threshold may work perfectly fine for one part of the text, but then turn the other part completely black. One way to fix this issue is by taking the mean of a certain amount of pixels, and applying that mean as a threshold for those pixels. There are two types of means that can be used: Gaussian mean, otherwise known as Normal distribution, and the arithmetic mean. We searched through the documentation for the processing openCV, but it did not tell us what type of mean it used. We determined that the 2nd parameter for adaptive thresholding, the c, adds a certain amount to the mean value. Setting this value to 1 worked best for us. The Adaptive Block Size changes the level of precision in the threshold filtering. Larger block sizes mean that the amount of times we will take the mean and compare it to each pixel inside the block will be less, while smaller values mean less pixel density per block. 

Finally for image filtering, we have the blur function. What this does is that it uses kernels to basically take the average of all of the pixels surrounding the pixel as well as itself. Now in the actual opencv source code, they use matrices to define the kernel and take this average, but literally just adding up every pixel around the central pixel as well as itself and then dividing by the number of pixels you added works just as well. The blur amount impacts how many pixels wide we will take the average of. The larger the amount of pixels we will take the average of, the more blurry it gets, as each individual pixel now basically weighs less compared to the finalized result. While you may think this kind of thing seems useless for our use, by combining this, smoothing, and edge detecting or the previously stated thresholding, we can make much clearer images. However, one problem we came into, in the middle of implementing this smoothing algorithm, was that the actual library had no smoothing algorithm. We got stuck trying to convert PImages into matrices and using the Java OpenCV version, and we ended up giving up later. However, we can show you what it looks like when you combine blur and threshold together. If you do look at it, it seems as though the edges have been wiped out. This is usually what blur does, as it simplifies the image a lot. However, if we combined it with smoothing, we could get rid of “details” which don't need to isolate the object we actually want. 

That was the 3 different functions for image filtering. I will now move on to edge detection with filters. Once again, the OpenCV library makes it really easy to do these filters. 

These filters are a bit more complicated compared to the last 3, but this again uses the kernels that we described in the intro. To get this out of the way, the Sobel filter and the Scharr filter use the same basic concept, but the Scharr filter builds off of the Sobel filter by making it more efficient. For the Sobel filter, it first uses the first derivative of the gradients of the image, and then uses two kernels and effectively takes the pythagorean theorem and assumes that the values of the resulting kernels are the x and y values of a triangle. Thus, we can determine the angle and magnitude of the gradient to be applied.

By doing this, the Sobel filter can effectively clear the edges of any image out. 

As for the Canny filter, it starts out by reducing the noise of the image by applying a smoothing filter to the image. Next, it will do something similar to the Sobel filter, and apply two kernels to teach pixels and then again, find the pythagorean theorem of the kernels. After doing this, it will perform another smoothing operation to remove further noise. Finally, it will go through a stage of Hysteresis Thresholding, which is basically the robot at the end of the line that picks off any anomalies it sees. For this stage, similar to the threshold in our own edge detection algorithms. It will take a min and max threshold, and then check to see if the value of the edges fall between the two thresholds as well as if the edge is connected to another edge that is considered a sure edge, or an edge that falls outside the threshold in its beginning.

While these topics are extremely complicated and require advanced math to really understand what is happening, the OpenCV library simplifies it into a few simple functions. 

Finally, we have the Background Subtraction. For the processing version, it uses the MOG, short for Gaussian Mixture-based Background/Foreground Segmentation Algorithm, version of the Background Subtraction in OpenCV. What background subtraction does is that it models each background pixel as a mixture of Gaussian distributions. Gaussian distributions are modeled by this extremely complicated formula:

The basic idea of this is that the algorithm checks to see how LONG the pixel has stayed on the screen for. If it stays on the screen for longer, then it makes it more likely that the pixel is a background pixel. Using this, we can determine what pixels aren’t a part of the background and mark them out with a red dotted line. This is where probability really comes in, and everything becomes a huge mess of complicated college math. While Gaussian distributions and the actual formula for MOG are extremely difficult topics to understand, I think this library does a good job in removing the unnecessarily complicated math behind each feature and you simply just have to implement a few lines of code based on their reference. 

Now that I have finished explaining, I will talk about a few issues we encountered with the OpenCV library. The reference on the github did very little to actually explain what each parameter of the functions did, and some had no explanation at all. Thus, we found that it was hard for us to really get a good grasp on what some of the functions really did and how changing the parameters would affect it. We also found that a few of the functions built into the Java version of OpenCV were not available for the processing version. One function we tried to use, smoothing, which was nowhere to be found on the OpenCV reference, and when we looked into the OpenCV main file, it was also not found. We also noticed that the github was not updated for almost 5 years, which might explain the lack of some functionality and reference. Also, some of the code was still using older versions of algorithms in OpenCV, like the MOG background subtraction had actually been updated to a MOG 2 version, yet no changes were made. 