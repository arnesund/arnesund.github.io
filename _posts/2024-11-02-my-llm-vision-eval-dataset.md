# Making a tiny personal benchmark dataset for vision-LLMs

New LLMs pop up every day it seems, so having a way to do a quick vibe check of each is important. This post introduces my small personal photo benchmark dataset that reflects images typically found in my smartphone's camera roll.

The use-case I have in mind is to get a vision-LLM to automatically describe all my photos and screenshots from 20 years of digital photography. Since that needs to happen using batch processing, there's no room for follow-up questions or other techniques to improve a description. Once I choose a model I'll do some additional prompt tuning to get the best possible results from that model, but it'll still be just one request per image.

## Dataset Overview

Each image serves a specific purpose in testing different aspects of vision LLMs' capabilities. There's currently a bit much from Pokemon Go here, but on the other hand I still play and document achievements by taking screenshots so those screenshots are easily half of my camera roll too.

For each vision-capable LLM, I'll post each image along with a small prompt, typically "Describe the photo or screenshot". Different prompts might tease out higher quality descriptions of course, but we're doing a vibe check here and the most important part of that is the ability to discard a model as not interesting quickly.

Below each image I'll include the output from each model I've tested. Plus a description of which models I still consider good or even best.

## 1. Pokemon Go collection challenge

The first image showcases a Pokémon GO collection challenge screenshot, testing the model's ability to interpret gaming interfaces and recognize specific game elements.

![Pokemon Go Collection Challenge](/assets/images/test1.png)

### Llama 3.2 11B vision-instruct

<small>
This image shows a screenshot of a screen display on an iPhone, with a green and blue gradient background featuring level lines of a bike path. At the top left are the time "14:06" in white, wireless data signal strength, and battery level. In the center, below the section saying "Congratulations!", is a gold ring around an image showing a medal with the number 77.

The slider bar is at the bottom, and the area is green at the top, transitioning to blue over a map or road and houses. There are lines that look like level bars on a road on the right and light green text on the right side, saying "5:05:30" and "SHARE". The bottom of the slider bar has a light green rounded rectangle with white "SHARE" text next to a light-green circle with a white outline to its right. Below it is a similar-looking blue button with white "SAVE IMAGE" text and the Save photo icon.

Additionally, there are two small-scale logos near the top on the left side. The first one is marked “Airspodcast” in white text. The image suggests that it may be a crossword puzzle game since the surrounding levels do not display any clues as to what game it is.
</small>

**Not great**: Did not mention the name of the game (Pokemon Go). Very good at OCR-ing the text, but not good enough at describing what the screenshot most likely represents.

Tested using OpenRouter on 2024-11-02.


## 2. Photo of a natural, rural scene

A landscape photograph featuring power lines against a natural backdrop. What we want to see here is the ability to describe the scene, the objects included and the overall feel of it.

![Field with Power Lines](/assets/images/test2.jpg)

### Llama 3.2 11B vision-instruct

<small>
This serene landscape image captures a farmland landscape at dusk, with a row of power lines extending from the right to move background a row of trees, fading into the sky's warm hues of blue, pink, orange, and yellow. In the foreground, a tree is silhouetted in a field of green grass, which gradually transitions to dry fields. Beyond the row of power lines, trees line the far horizon, with a red building peeking through the silhouette of the towers and trees. The image exudes a sense of tranquility and peacefulness, conveying a feeling of time spent in rural solitude.
</small>

**Okay**: I've seen better descriptions than this, but it's certainly good enough.

Tested using OpenRouter on 2024-11-02.

### 3. Interactive Game Elements
![Pokemon Go Catch Scene](/assets/images/test3.png)
A Pokémon GO catch scene screenshot, challenging the model's ability to recognize dynamic gaming elements and specific game mechanics.

### 4. Text Recognition and Product Details
![Gainomax Product](/assets/images/test4.jpg)
A detailed shot of a Gainomax product, specifically chosen to test Optical Character Recognition (OCR) capabilities and product detail identification.

### 5. Pokedex Recognition
![Pokemon Go Pokedex](/assets/images/test5.png)
A Pokémon GO Pokédex screenshot, testing the model's ability to interpret structured game information.

### 6. Technical Documentation
![Electrical Saw](/assets/images/test6.jpg)
An electrical saw photograph with technical specifications, evaluating the model's capability to process and understand technical product information.

## Usage

This benchmark is my go-to set of images to throw at any vision-capable LLM to do a quick evaluation of:
- Accuracy of scene description
- Text recognition capabilities
- Understanding of technical specifications
- Game interface interpretation

By using a consistent set of images across different models, we can better understand their relative strengths and limitations in real-world applications.

