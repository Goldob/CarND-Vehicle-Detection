**Vehicle Detection Project**

The goals / steps of this project are the following:

* Perform a Histogram of Oriented Gradients (HOG) feature extraction on a labeled training set of images and train an SVM classifier
* Optionally, you can also apply a color transform and append binned color features, as well as histograms of color, to your HOG feature vector.
* Note: for those first two steps don't forget to normalize your features and randomize a selection for training and testing.
* Implement a sliding-window technique and use your trained classifier to search for vehicles in images.
* Run your pipeline on a video stream (start with the test_video.mp4 and later implement on full project_video.mp4) and create a heat map of recurring detections frame by frame to reject outliers and follow detected vehicles.
* Estimate a bounding box for vehicles detected.

[//]: # (Image References)
[image1]: ./output_images/hog.png

[image2]: ./output_images/sliding_window_32x32.png
[image3]: ./output_images/sliding_window_64x64.png
[image4]: ./output_images/sliding_window_96x96.png

[image5]: ./output_images/detections_test1.png
[image6]: ./output_images/detections_test4.png
[image7]: ./output_images/detections_test5.png

[image8]: ./output_images/detections_test6.png
[image9]: ./output_images/heatmap_test6.png
[image10]: ./output_images/threshold_test6.png
[image11]: ./output_images/result_test6.png

[video1]: ./project_video.mp4

## [Rubric](https://review.udacity.com/#!/rubrics/513/view) Points
### Here I will consider the rubric points individually and describe how I addressed each point in my implementation.  

---
### Writeup / README

#### 1. Provide a Writeup / README that includes all the rubric points and how you addressed each one.  You can submit your writeup as markdown or pdf.  [Here](https://github.com/udacity/CarND-Vehicle-Detection/blob/master/writeup_template.md) is a template writeup for this project you can use as a guide and a starting point.  

You're reading it!

### Histogram of Oriented Gradients (HOG)

#### 1. Explain how (and identify where in your code) you extracted HOG features from the training images.

_The code for this step is contained in the second code cell of the IPython notebook located in `./solution.ipynb`._

For feature extraction, I used a simple HOG based on grayscale image. I used 9 gradient orientations, cell size of 16x16 and block size of 2x2. These parameter values proved to provide satisfying results without making the feature vector too large (which would both increase the processing time and the risk of overfitting). Resulting feature vector had the length of 384. The visualization below showcases HOG computed on an example car image.

![alt text][image1]

#### 2. Describe how (and identify where in your code) you trained a classifier using your selected HOG features (and color features if you used them).

_The code for this step is contained in the fourth and fifth code cells of the IPython notebook located in `./solution.ipynb`._

After extracting the feature vector, I normalized it using `sklearn.preprocessing.StandardScaler`. Next, I fed the normalized features into an SVM classifier. I used `sklearn.model_selection.GridSearchCV` to find optimal hyperparameter configuration.

### Sliding Window Search

#### 1. Describe how (and identify where in your code) you implemented a sliding window search.  How did you decide what scales to search and how much to overlap windows?

_The code for this step is contained in the seventh to nineth code cells of the IPython notebook located in `./solution.ipynb`._

I decided to search the scene with multiple window dimensions to account for the perspective effect (more distant vehicles appearing to be smaller). I restricted the search areas to specific regions of interest, based on where the vehicles are expected to appear in the image. I also chose overlap factor as a trade-off between search accuracy and computation time (more overlap leads to more windows leads to longer processing).

| Window dimensions | Number of windows | Visualization       |
|:-----------------:|:-----------------:|:-------------------:|
| 32x32             | 46                | ![alt text][image2] |
| 64x64             | 135               | ![alt text][image3] |
| 96x96             | 100               | ![alt text][image4] |

#### 2. Show some examples of test images to demonstrate how your pipeline is working.  What did you do to optimize the performance of your classifier?

The switch to non-linear SVM kernel and use of automatic hyperparameter tuning allowed for the improvement in classifier accuracy on the test set from 94.617% to 98.806%. This had also a clear effect on the overall performance of the pipeline, reducing the number of both false positives and false negatives.

![alt text][image5]
![alt text][image6]
![alt text][image7]

As can be seen in the last example, false positives have not been completely eliminated from the classifier. However, an additional step described below allows to filter them out.

---

### Video Implementation

#### 1. Provide a link to your final video output.  Your pipeline should perform reasonably well on the entire project video (somewhat wobbly or unstable bounding boxes are ok as long as you are identifying the vehicles most of the time with minimal false positives.)
Here's a [link to my video result](./project_video.mp4).


#### 2. Describe how (and identify where in your code) you implemented some kind of filter for false positives and some method for combining overlapping bounding boxes.

I recorded the positions of positive detections in each frame of the video.  From the positive detections I created a heatmap and then thresholded that map to identify vehicle positions.  I then used `scipy.ndimage.measurements.label()` to identify individual blobs in the heatmap.  I then assumed each blob corresponded to a vehicle.  I constructed bounding boxes to cover the area of each blob detected.  

Here's an example:

### Positive detections

![alt text][image8]

### Heatmap

![alt text][image9]

...after thresholding:

![alt text][image10]

### Result

![alt text][image11]

For simplicity, the above demonstration shows the elimination of false positives based on a single frame. The process is similar when analysing video, but the heatmap is generated from detections in multiple consecutive frames. This makes the whole pipeline more robust by allowing to track detections over time and discard anomalies.

---

### Discussion

#### 1. Briefly discuss any problems / issues you faced in your implementation of this project.  Where will your pipeline likely fail?  What could you do to make it more robust?

I decided to take an incremental approach to my solution by building the most simple model first and fixing its shortcomings only when necessary. This way I could get faster to a working prototype and build up from that.

My initial implementation involved a linear SVM. Despite decent accuracy on the test set, there was a lot of false positives in the video. I tackled the problem by using a more complex RBF kernel and running `GridSearchCV` to find the best hyperparameters configuration and further improve the performance.

After I was satisfied with classifier performance, I had to address odd sizes of bounding boxex (sometimes two times larger than the contained vehicles). The issue here was that the sliding windows were too big and the step between consecutive positions was too large, negatively affecting accuracy. The solution was to fine-tune sliding window configurations.

It should be noted, however, that the pipeline is still far from perfect. There are still a few false positives here and there and the detection doesn't work so well with vehicles that are just entering the field of view or are far away. Different lighting conditions not present in the dataset could also pose issues. One solution to that might be appropriate data augmentation during training.
