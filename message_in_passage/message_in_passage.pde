/**
 * MESSAGE IN PASSAGE
 * Haena Cho
 *  
 * Message in Passage is a digital postbox system that allows the sending and retrieving of messages 
 * while the sent messages visually decay over time (letters fade and images erode, embracing the passage of time).
 */

/*********
 LIBRARIES
 *********/
import org.gicentre.handy.*;
HandyRenderer h;

/******
 GLOBAL
 ******/
ArrayList <Message> messages = new ArrayList <Message> ();
Message choice;
int choiceIndex;

/**************
 IMAGES & FONTS
 **************/
PImage postbox, paperBefore, paperAfter, photoTexture;
PFont systemFont;
PFont letterFont;

/*********
 CONSTANTS
 *********/
final int MAIN = 0;
final int SEND = 1;
final int WRITE_LETTER = 2;
final int UPLOAD_PHOTO = 3;
final int RETRIEVE = 4;
final int READ_MESSAGE = 5;
final int VIEW_PHOTO = 6;

// default mode @ main screen
int mode = MAIN;

// title
final int TITLE_Y = 200;

// buttons
final int BUTTON_LEFT = 480;
final int BUTTON_RIGHT = 1440;
final int BUTTON_Y = 700;
final int BUTTON_SIZE = 100;

// parcels
color [] parcelColors = {#F2E9D8, #D9C5A3, #B59A72, #3A3A3A};

// letter layout
final int LETTER_X = 960;
final int LETTER_Y = 540;
final int LETTER_WIDTH = 440;
final int LETTER_HEIGHT = 560;
final int TEXT_WIDTH = 300;
final int TEXT_HEIGHT = 400;

// photo frame layout
final int FRAME_X = 960;
final int FRAME_Y = 540;
final int FRAME_WIDTH = 640;
final int FRAME_HEIGHT = 480;
final int PHOTO_WIDTH = 400;
final int PHOTO_HEIGHT = 300;

// input
String letterInput = "";
Photo previewPhoto;
String uploadedPhoto;

boolean emptyAlert = false;
boolean waitingForPhoto = false;

// decay
float decayRate = 0.01; // change this value to adjust the overall speed of decay

// retrieve
int retrieveTime = 0;
boolean alertOn = false;


void setup () {
    size (1920, 1080);

    systemFont = createFont ("Author-Handwriting.otf", 56);
    letterFont = createFont ("Corethan-Bold.otf", 18);
    textAlign (CENTER);

    postbox = loadImage ("images/postbox.png");
    paperBefore = loadImage ("images/paper-before.png");
    paperAfter = loadImage ("images/paper-after.png");
    photoTexture = loadImage ("images/photo-texture.png");
    imageMode (CENTER);

    h = new HandyRenderer (this);
    h.setOverrideFillColour (true);
}

void draw () {
    background (255);

    switch (mode) {
        case MAIN :
            drawMain ();
            break;

        case SEND :
            drawSend ();
            break;

        case WRITE_LETTER :
            drawWriteLetter ();
            break;

        case UPLOAD_PHOTO :
            drawUploadPhoto ();
            break;

        case RETRIEVE :
            drawRetrieve ();
            break;

        case READ_MESSAGE :
            drawReadMessage ();
            break;
    }

}

/***************
 MODE INTERFACES
 ***************/

void drawMain () {
    image (postbox, 960, 540, 600, 600);

    // reset empty alert
    emptyAlert = false;

    // draw parcels
    for (int i = 0; i < messages.size (); i++) {
        messages.get (i).decay ();

        strokeWeight(2);
        h.setSeed (messages.get (i).parcelSeed);
        h.setBackgroundColour (messages.get (i).parcelColor);
        h.rect (960, 720 - (30 * i), 210, 30);
    }

    drawButton ("send", BUTTON_LEFT);
    drawButton ("retrieve", BUTTON_RIGHT);
}

void drawSend () {
    image (postbox, 960, 900, 1200, 1200);

    drawTitle ("send what?");
    drawButton ("letter", BUTTON_LEFT);
    drawButton ("photo", BUTTON_RIGHT);
}

void drawWriteLetter () {
    drawTitle ("write your message: ");

    // letter background
    image (paperBefore, LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);
    noFill ();
    rectMode (CENTER);
    h.setSeed (1234);
    strokeWeight(2);
    h.rect (LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);

    // text area
    fill (0, 200);
    textFont (letterFont);
    textLeading (36);
    textAlign (LEFT);
    text (letterInput, LETTER_X, LETTER_Y, TEXT_WIDTH, TEXT_HEIGHT);

    // alert when letter is empty
    if (emptyAlert) {
        fill (color (#e23d45));
        textFont (systemFont);
        textSize (40);
        textAlign (CENTER);
        text ("you cannot send an empty message", 960, 920);
    }

    drawButton ("cancel", BUTTON_LEFT);
    drawButton ("send", BUTTON_RIGHT);
}

void drawUploadPhoto () {
    drawTitle ("upload your picture: ");

    image (paperBefore, FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
    noFill ();
    rectMode (CENTER);
    h.setSeed (1234);
    strokeWeight(2);
    h.rect (FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
    
    if (previewPhoto == null) {
        h.setBackgroundColour (color (180, 165, 140));
        fill (color (180, 165, 140));
        h.rect (FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);

        drawButton ("select photo", FRAME_X, FRAME_Y - 30, 40, 255);
    } else {
        image (previewPhoto.original, FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
        noFill ();
        h.rect (FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);

        drawButton ("change photo", FRAME_X, FRAME_Y - 30, 40, 255);
    }

    // alert when photo is not selected
    if (emptyAlert) {
        fill (color (#e23d45));
        textFont (systemFont);
        textSize (40);
        textAlign (CENTER);
        text ("you cannot send an empty message", 960, 920);
    }

    drawButton ("cancel", BUTTON_LEFT);
    drawButton ("send", BUTTON_RIGHT);
}

void drawRetrieve () {
    image (postbox, 960, 160, 1200, 1200);
    
    // if there is nothing to retrieve, 
    // alert and go back to main screen
    if (messages.size() == 0) {
        if (!alertOn) {
            retrieveTime = millis();
            alertOn = true;
        }

        drawTitle ("there is nothing to retrieve", 880);

        // wait for 2 sec and go back to main screen
        if (millis() - retrieveTime > 2000) {
            mode = 0;
            // reset flag
            alertOn = false;
        }
    } else {
        alertOn = false;

        // display message in forms of parcels
        for (int i = 0; i < messages.size(); i++) {
            messages.get(i).decay();

            strokeWeight(4);
            h.setSeed (messages.get (i).parcelSeed);
            h.setBackgroundColour (messages.get (i).parcelColor);
            h.rect (960, 520 - (60 * i), 420, 60);
        }

        drawTitle ("retrieve what?", 880);
        drawButton ("cancel", 960, 930, 40);
    }
}

void drawReadMessage () {
    // display the message
    choice.display ();

    noFill ();
    strokeWeight(2);
    rectMode (CENTER);
    h.setSeed (1234);

    // display message frames
    if (choice instanceof Letter) {
        h.rect (LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);
    } else if (choice instanceof Photo) {
        h.rect (FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
        h.rect (FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
    }
    
    drawButton ("put back", BUTTON_LEFT);
    drawButton ("throw away", BUTTON_RIGHT);
}


/****************
 TITLES & BUTTONS
 ****************/

void drawTitle (String label) {
    fill (0);
    textFont (systemFont);
    textAlign (CENTER);
    text (label, 960, TITLE_Y);
}

// overload
void drawTitle (String label, int y) {
    fill (0);
    textFont (systemFont);
    textAlign (CENTER);
    text (label, 960, y);
}

void drawButton (String label, int x) {
    fill (30);
    textFont (systemFont);
    textSize (48);
    textAlign (CENTER);
    text (label, x, BUTTON_Y);
}

// overload
void drawButton (String label, int x, int y, int fontSize) {
    fill (30);
    textFont (systemFont);
    textSize (fontSize);
    textAlign (CENTER);
    text (label, x, y);
}

// overload
void drawButton (String label, int x, int y, int fontSize, int fontColor) {
    fill (fontColor);
    textFont (systemFont);
    textSize (fontSize);
    textAlign (CENTER);
    text (label, x, y);
}

boolean buttonClicked (int x, int y) {
    return dist (x, y, mouseX, mouseY) < BUTTON_SIZE;
}


/*******
 CLASSES
 *******/

abstract class Message {
    float timestamp;
    boolean isOpened = false;
    int parcelSeed;
    color parcelColor;

    Message () {
        timestamp = millis ();
        parcelSeed = int (random (1234));
        parcelColor = parcelColors [int (random (parcelColors.length))];
    }

    abstract void decay ();
    void display () {isOpened = true;}
    void close () {isOpened = false;}
}

class Letter extends Message {
    String content;
    float [] characterOpacity;
    float letterOpacity = 255;

    Letter (String tempContent) {
        super ();
        content = tempContent;

        // all characters are fully visible at first
        characterOpacity = new float [content.length ()];
        for (int i = 0; i < characterOpacity.length; i++) {
            characterOpacity [i] = 1.0;
        }
    }

    // override
    void decay () {
        if (isOpened) {return;}

        // calculate time passage (in secs) 
        float age = millis () - timestamp;
        int decayCount = int (age / 1000);

        // random characters fading
        for (int i = 0; i < decayCount * 20; i++) {
            int index = int (random (content.length ()));
            characterOpacity [index] = max (0, characterOpacity [index] - decayRate * 0.01);
        }

        // background letter eroding
        letterOpacity = min (255, 500 * decayCount * decayRate);    
    }

    // override
    void display () {
        super.display ();

        // display letter background
        tint (255, 255);
        image (paperBefore, LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);

        // decay layer
        tint (255, letterOpacity);
        image (paperAfter, LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);
        // reset tint
        tint (255, 255);

        // display text
        textFont (letterFont);
        textLeading (36);
        textAlign (LEFT);

        // set text position
        float x = LETTER_X - TEXT_WIDTH / 2;
        float y = LETTER_Y - TEXT_HEIGHT / 2;

        // display letter contents character by character
        for (int i = 0; i < content.length (); i++) {
            char c = content.charAt (i);

            // line change
            if (c == '\n' || x > 1110 - textWidth (str (c)) / 2) {
                x = LETTER_X - TEXT_WIDTH / 2;
                y += 36;
            }

            fill (0, characterOpacity [i] * 255);
            text (c, x, y);
            x += textWidth (str (c));
        }
    }
}

class Photo extends Message {
    PImage original;
    PImage decayed;
    boolean [] pixelFiltered;
    float frameOpacity = 255;

    Photo (String filename) {
        super ();
        original = loadImage (filename);
        original.resize (PHOTO_WIDTH, PHOTO_HEIGHT);
        
        // create a copy of the image 
        decayed = createImage (PHOTO_WIDTH, PHOTO_HEIGHT, RGB);
        decayed.copy (original, 0, 0, PHOTO_WIDTH, PHOTO_HEIGHT, 0, 0, PHOTO_WIDTH, PHOTO_HEIGHT);

        original.loadPixels ();
        pixelFiltered = new boolean [original.pixels.length];
    }

    // override
    void decay () {
        if (isOpened) {return;}

        // calculate time passage (in secs) 
        float age = millis () - timestamp;
        int decayCount = int (age / 1000);

        original.loadPixels ();
        decayed.loadPixels ();

        // change the pixel's brightness value to 255 (white) or 0 (black)
        // depending on whether the original value is over 130 or not
        // base code attribution: https://funprogramming.org/90-Change-pixel-hue-saturation-and-brightness.html
        for (int i = 0; i < decayCount * 20; i++) {
            int index = int (random (original.pixels.length));

            if (!pixelFiltered [index]) {
                float b = brightness (original.pixels [index]);

                if (b > 130) {
                    decayed.pixels [index] = color (255);
                } else {
                    decayed.pixels [index] = color (0);
                }
            }

            pixelFiltered [index] = true;
        }

        decayed.updatePixels ();

        // background frame eroding
        frameOpacity = min (255, 500 * decayCount * decayRate);
    }

    void display () {
        super.display ();

        // display photo frame background
        tint (255, 255);
        image (paperBefore, FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);

        // decay layer
        tint (255, frameOpacity);
        image (paperAfter, FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
        // reset tint
        tint (255, 255);

        // display photo
        image (decayed, FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);

        // decay layer
        tint (255, frameOpacity * 0.5);
        image (photoTexture, FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
        // reset tint
        tint (255, 255);
    }
}


/*****
 INPUT
 *****/

 void mouseClicked () {
    switch (mode) {
        case MAIN :
            if (buttonClicked (BUTTON_LEFT, BUTTON_Y)) {
                mode = SEND;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                mode = RETRIEVE;
            }
            break;
        
        case SEND :
            if (buttonClicked (BUTTON_LEFT, BUTTON_Y)) {
                mode = WRITE_LETTER;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                mode = UPLOAD_PHOTO;
            }
            break;
        
        case WRITE_LETTER : 
            if (buttonClicked (BUTTON_LEFT, BUTTON_Y)) {
                emptyAlert = false;
                // reset letter
                letterInput = "";
                mode = MAIN;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                if (letterInput != "") {
                    emptyAlert = false;
                    messages.add (new Letter (letterInput));
                    // reset letter
                    letterInput = "";
                    mode = MAIN;
                } else {
                    emptyAlert = true;
                    // println ("no message written");
                }
            }
            break;

        case UPLOAD_PHOTO :
            if (buttonClicked (BUTTON_LEFT, BUTTON_Y)) {
                uploadedPhoto = null;
                previewPhoto = null;
                mode = MAIN;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                // send photo
                if (uploadedPhoto != null) {
                    emptyAlert = false;
                    messages.add (new Photo (uploadedPhoto));
                    uploadedPhoto = null;
                    previewPhoto = null;
                    mode = MAIN;
                } else {
                    emptyAlert = true;
                    // println ("no photo selected");
                }
            } else if (buttonClicked (FRAME_X, FRAME_Y - 30)) {
                emptyAlert = false;
                // upload photo
                waitingForPhoto = true;
                selectInput ("select a photo to send: ", "fileSelected");
            }
            break;
        
        case RETRIEVE :
            for (int i = 0; i < messages.size (); i++) {
                if (dist (960, 520 - (60 * i), mouseX, mouseY) < 50) {
                    choice = messages.get (i);
                    choiceIndex = i;
                    mode = READ_MESSAGE;
                }
            }

            if (buttonClicked (960, 920)) {
                mode = MAIN;
            }
            break;
        
        case READ_MESSAGE :
            if (buttonClicked (BUTTON_LEFT, BUTTON_Y)) {
                choice.close ();
                mode = RETRIEVE;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                messages.remove (choiceIndex);
                mode = RETRIEVE;
            }
            break;
    }
 }

 void keyTyped () {
    if (mode == WRITE_LETTER) {
        emptyAlert = false;

        if (key == BACKSPACE && letterInput.length() > 0) {
            letterInput = letterInput.substring(0, letterInput.length() - 1);
        } else if (key == ENTER || key == RETURN) {
            letterInput += "\n";
        } else if (key != CODED) {
            letterInput += key;
        }
    }
 }

 void fileSelected (File selection) {
    emptyAlert = false;

    if (selection == null) {
        println ("no photo selected");
        uploadedPhoto = null;
        previewPhoto = null;
        waitingForPhoto = false;
        return;
    } 

    uploadedPhoto = selection.getAbsolutePath ();
    previewPhoto = new Photo (uploadedPhoto);

    waitingForPhoto = false;
    mode = UPLOAD_PHOTO;
 }