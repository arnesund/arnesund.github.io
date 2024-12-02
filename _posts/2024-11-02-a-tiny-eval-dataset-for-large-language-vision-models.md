---
layout: post
title: "A Tiny Eval Dataset for Large Language Vision Models"
date: "2024-11-02"
categories:
  - "AI"
tags:
  - "llm"
  - "local llm"
  - "ollama"
  - "minicpm-v"
  - "llama"
---

# Making a tiny personal benchmark dataset for vision-LLMs

New LLMs pop up every day it seems, so having a way to do a quick vibe check of each is important. This post introduces my small personal photo benchmark dataset that reflects images typically found in my camera roll.

The use-case I have in mind is to get a vision-LLM to automatically describe all my photos and screenshots from 20 years of digital photography. Since that needs to happen using batch processing, there's no room for follow-up questions or other techniques to improve a description. Once I choose a model I'll do some additional prompt tuning to get the best possible results from that model, but it'll still be just one request per image.

## Dataset description

Each image serves a specific purpose in testing different aspects of vision LLMs' capabilities. There's currently a bit much from Pokemon Go here, but on the other hand I still play and document achievements by taking screenshots so those screenshots are easily half of my camera roll too.

I use a small prompt, typically something like "Describe the photo or screenshot", when testing each model. Different prompts might tease out higher quality descriptions of course, but we're doing a vibe check here and the most important part of that is the ability to discard a model as not interesting quickly.

Below each image I include an assessment of how each model did on that task. Expanding that assessment reveals the full output from the model, for those that want to inspect the details.

## Model summary

Scores are subjective from 0 to 10.

| Large Language Model          | Average | Image 1 | Image 2 | Image 3 | Image 4 | Image 5 | Image 6 | Tested at  |
|-------------------------------|---------|---------|---------|---------|---------|---------|---------|------------|
| Llama 3.2 11B Vision-Instruct |   5.2   |    3    |    8    |   10    |    8    |    0    |    2    | 2024-11-02 |
| MiniCPM-V 2.6                 |   9.7   |   10    |   10    |   10    |   10    |    8    |   10    | 2024-09-11 |

### Model test notes

**Llama 3.2 11B Vision-Instruct**:
Tested using OpenRouter. Most likely a FP8 or BF16 version of the model, although provider details are unclear. Prompt used: "Describe the photo or screenshot".

**MiniCPM-V 2.6**
Tested as a local model using Ollama, pulled from the Ollama library in the default Q4 quant. Prompt used: "Describe the photo or screenshot. Include keywords describing details of what the image contains. Include the name of the app or game if it’s a screenshot."

## 1. Pokemon Go collection challenge

The first image showcases a Pokémon GO collection challenge screenshot, testing the model's ability to interpret gaming interfaces and recognize specific game elements.

<img src="/assets/images/test1.png" alt="Pokemon Go Collection Challenge" style="max-width:300px;">

### Llama 3.2 11B Vision-Instruct: Not great

Did not mention Pokemon Go. Okay at OCR but not good at describing what the screenshot most likely represents.

<details>
<summary>
See full output
</summary>
This image shows a screenshot of a screen display on an iPhone, with a green and blue gradient background featuring level lines of a bike path. At the top left are the time "14:06" in white, wireless data signal strength, and battery level. In the center, below the section saying "Congratulations!", is a gold ring around an image showing a medal with the number 77.

The slider bar is at the bottom, and the area is green at the top, transitioning to blue over a map or road and houses. There are lines that look like level bars on a road on the right and light green text on the right side, saying "5:05:30" and "SHARE". The bottom of the slider bar has a light green rounded rectangle with white "SHARE" text next to a light-green circle with a white outline to its right. Below it is a similar-looking blue button with white "SAVE IMAGE" text and the Save photo icon.

Additionally, there are two small-scale logos near the top on the left side. The image suggests that it may be a crossword puzzle game since the surrounding levels do not display any clues as to what game it is.
</details>

### MiniCPM-V 2.6: Great

Getting to the point quickly and including all necessary details.

<details>
<summary>
See full output
</summary>
The image is a screenshot from the game 'Pokémon Go,' showing the player's achievement of completing a Collection Challenge. The screen displays a congratulatory message in bold, white text against a vibrant green background with an overlay of faint city outlines and icons related to gameplay options such as weather conditions or health status at the top right corner.

Key elements include:
- A golden coin icon indicating '77' - likely representing collected items.
- Instructions encouraging players to see their Elite Collector medal in-game for all completed challenges, which is highlighted by a circular button with an upward arrow and text "SHARE" above it and another labeled "SAVE IMAGE" below it.

The user's username appears at the bottom left corner, along with some numerical data indicating game statistics. The overall theme suggests progression within the gameplay towards collecting items or completing specific objectives, which is a common feature in augmented reality games like Pokémon Go aimed at encouraging exploration and strategy among players to collect various in-game creatures known as 'Pokémon.'
</details>


## 2. Photo of a natural, rural scene

A landscape photograph featuring power lines against a natural backdrop. What we want to see here is the ability to describe the scene, the objects included and the overall feel of it.

<img src="/assets/images/test2.jpg" alt="Field with Power Lines" style="max-width:600px;">

### Llama 3.2 11B Vision-Instruct: Okay

I've seen better descriptions than this, but it's certainly good enough.

<details>
<summary>
See full output
</summary>
This serene landscape image captures a farmland landscape at dusk, with a row of power lines extending from the right to move background a row of trees, fading into the sky's warm hues of blue, pink, orange, and yellow. In the foreground, a tree is silhouetted in a field of green grass, which gradually transitions to dry fields. Beyond the row of power lines, trees line the far horizon, with a red building peeking through the silhouette of the towers and trees. The image exudes a sense of tranquility and peacefulness, conveying a feeling of time spent in rural solitude.
</details>

### MiniCPM-V 2.6: Great

<details>
<summary>
See full output
</summary>
This image captures a serene rural scene at dusk. The sky is transitioning from day to night, with the sun setting on the horizon and casting a warm glow across the landscape. Power lines are prominently featured in the foreground, leading into the distance where they converge near some buildings partially visible through the trees. A field of tall grass occupies most of the lower half of the image, adding texture and depth to the scene. The overall mood is peaceful and contemplative, evoking a sense of tranquility as day turns to evening.

Keywords: rural landscape, dusk, power lines, fields, sunset, tranquil atmosphere
</details>

## 3. Pokemon Go catch scene

Finding rare pokemon is always fun and a common reason to take a screenshot. To catalogue them later and make them searchable, we at least need to know that it's Pokemon Go and the name of the pokemon.

<img src="/assets/images/test3.png" alt="Pokemon Go Catch Scene" style="max-width:300px;">

### Llama 3.2 11B Vision-Instruct: Great

Very detailed, possibly too detailed. But that's not a problem for search and embedding use-cases. 

<details>
<summary>
See full output
</summary>
The image shows a screenshot of a phone screen with the Pokémon character Snorlax in the center, surrounded by trees and mountains. The overall atmosphere is peaceful and serene, suggesting a morning or daytime setting.

Here are the key elements of the image:
* **Snorlax:**
	+ Standing in the center of the image
	+ Blue and white fur
	+ Red eyes
	+ White belly
* **Trees:**
	+ Red and orange leaves
	+ Green leaves on some trees
	+ Varieties of trees, including deciduous and evergreen
* **Mountains:**
	+ Blue-gray color
	+ Faint outlines
	+ Blurred in the background
* **Sky:**
	+ Light blue color
	+ White clouds
	+ Sun or moon not visible
* **Text:**
	+ "Bonus Challenge!" written in white font
	+ "Catch Snorlax!" written below the first line

Overall, the image appears to be a screenshot from a Pokémon game, possibly a bonus challenge level where the player must catch Snorlax. The peaceful atmosphere and serene surroundings suggest a morning or daytime setting, but the exact time of day is not specified.
</details>

### MiniCPM-V 2.6: Great

Has all the required details and doesn't over-explain.

<details>
<summary>
See full output
</summary>
The image depicts a vibrant scene from the Pokémon Go mobile game. At its center is Snorlax, a large blue and white Pokémon with pink cheeks, sitting in an open field surrounded by colorful autumnal trees showcasing shades of red and purple leaves against a clear sky. The text "Bonus Challenge! Catch Snorlax!" appears prominently across the image, indicating that players have successfully caught this rare Pokémon during their gameplay session.

Key details include:
- Time display at the top left corner reading '06:36'.
- Network signal indicator showing 4G with a full battery.
- The colorful and lively environment of the game's setting represents typical in-game exploration areas.
</details>


## 4. Text recognition in product snapshots

A detailed shot of a Gainomax product, specifically chosen to test OCR capabilities and product detail identification. Taking images of random products to remember their specs is something I often do. And I'm rarely able to find the images back later, hence why I need searchable descriptions.

<img src="/assets/images/test4.jpg" alt="Gainomax Product" style="max-width:300px;">

### Llama 3.2 11B Vision-Instruct: Almost great

First time seeing a LLM output a typo like "brpwn". The rest of the output ticks the various boxes.

<details>
<summary>
See full output
</summary>
This photograph depicts a container of Gainomax Choco Coffee High Protein drink. The white container features white cap, with the brand name "Gainomax" in upper case, and "Choco Coffee" in a larger, brown font accenting the "C". The packaging communicates nutritional information: "High Protein" alongside a white number 30 and "No Added Sugar", as well as its volume (250 ml).

The front of the carton features brpwn liquid splatters,  a partial view of a coffee bean, and an image of chocolate depicting the melting of a square cube of chocolate.

The container rests on a light brown wooden surface, with the wood displaying distinctive curly grain, some of which overtops the edges.

Overall, this image showcases a nutritional beverage product, highlighting its unique flavor and key features while emphasizing its health benefits, making it an attractive option for consumers seeking a convenient and nutritious drink.
</details>

### MiniCPM-V 2.6: Great

Recognizes all the text and interprets it correctly.

<details>
<summary>
See full output
</summary>
This image displays a product, specifically a carton of 'Gainomax Choco Coffee' which is marketed as high protein and without added sugar. It's positioned on a wooden surface with the brand name prominently displayed at the top in bold black letters against a white background. The front of the packaging features images of chocolate pieces, coffee beans, and chunks of cocoa, emphasizing its flavor profile. Key details include '30g PROTEIN' highlighted as one of its main selling points, accompanied by other claims like 'NO ADDED SUGAR'. It's 250 ml in volume. The overall setting suggests a focus on health-conscious consumers interested in nutritional supplements or high-protein beverages.
</details>


## 5. Pokedex Recognition

A Pokémon GO Pokédex screenshot, testing the model's ability to interpret structured game information.

<img src="/assets/images/test5.png" alt="Pokemon Go Pokedex" style="max-width:300px;">

### Llama 3.2 11B Vision-Instruct: Failed

The LLM misunderstands, this is not a login screen.

<details>
<summary>
See full output
</summary>
The image shows the top half of a cell phone screen displaying the Pokémon Go login screen, with the phone's battery life and signal strength visible. The screen features a pink and purple background with a 3D rendering of a Pokémon, a banner indicating that the user is registered to Pokédex, nine Pokémons in boxes, as well as a time and character selection

Overall, the image suggests that the user has just logged in to their Pokémon Go account and is now ready to play the game, with the top half of the screen displaying the login screen and the bottom half displaying the user's profile information.
</details>

### MiniCPM-V 2.6: Okay

Gets the overall theme correct but not all the details.

<details>
<summary>
See full output
</summary>
The image depicts a scene from the mobile game "Pokémon GO." It shows an in-game notification at the top indicating that it's 20:50, with signal strength bars and battery life displayed. A Pokémon named Saltyshark is shown above this notification, rendered in a simplistic low-poly art style against a pink gradient background. Below are icons representing various items or creatures within the game, including other Pokémon such as Articuno, Piplup, Vulpix, and others. The text "Registered to Pokédex" suggests that an item has been added to this virtual encyclopedia feature in-game.

Keywords: mobile app screenshot, Pokémon GO, notification bar, 20:50 time display, Saltyshark creature model, low-poly art style, pink gradient background, icons representing different items or creatures.
</details>


## 6. Technical Documentation

An electrical saw with technical specifications, evaluating the model's capability to process and understand technical product information and do accurate OCR. I also ideally want it to understand the Norwegian name of the product and either refer to it as-is or translated to English.

<img src="/assets/images/test6.jpg" alt="Electrical Saw" style="max-width:600px;">

### Llama 3.2 11B Vision-Instruct: Quite bad

It only recognizes some of the specifications like the power rating and voltage. It completely misses the name of the product (it's a saw) and goes on too much about the wires and plates and whatnot.

<details>
<summary>
See full output
</summary>
The image shows a close-up view of an electrical device with wires and cables attached to it. The device is black and has a yellow label on the front.

* A yellow label on the front of a black device:
	+ The label is rectangular in shape
	+ It has a yellow background with black text
	+ The text includes information about the device's specifications, such as its power rating (800W), voltage (230V/50Hz), and frequency (50Hz)
	+ There are also some symbols and markings on the label, including a circular symbol and a line drawing of a plug
* Black wires and cables attached to the device:
	+ The wires are thick and black in color
	+ They are attached to the top and sides of the device
	+ There are several wires, but they are all connected to each other in a single bundle
* A blue metal plate underneath the device:
	+ The plate is flat and rectangular in shape
	+ It is positioned directly underneath the device
	+ The plate has a slight curvature to it, suggesting that it may be a mounting surface for the device

Overall, the image suggests that the device is an electrical component, possibly a motor or generator, and that it is designed to be mounted on a surface or connected to external wires. The yellow label provides important information about the device's specifications and performance characteristics.
</details>

### MiniCPM-V 2.6: Great

Recognizes the product, does OCR of model number, power rating and all other mentioned details.

<details>
<summary>
See full output
</summary>
This image appears to be a photograph of an electrical device, specifically labeled as "Kapp- og gjæringssag" which translates from Norwegian or Swedish to 'cover and securing tool'. The label on the box provides technical specifications for this particular model. Key details include:

1. **Model Number**: M1YT-3Z0-205
2. **Power Rating**: 800W, indicating its electrical power consumption.
3. **Voltage and Frequency**: 230V/50Hz, specifying the voltage and frequency at which it should be operated (common for Europe).
4. **Dimensions**:
   - Ø205 x 30 mm
   - Height: 1.6 cm
5. **Speed**: 4500R.P.M., referring to its rotational speed.
6. **Certifications**: The box displays several certification marks indicating compliance with various safety and quality standards, including CE marking which ensures that the product meets EU health, safety, and environmental protection requirements.

The device is mounted on what seems like a piece of machinery or workbench setup, suggesting it's used in an industrial or workshop environment. Given its robust build and professional labeling, this tool likely serves as part of larger equipment for specific tasks requiring securement or covering operations.
</details>
