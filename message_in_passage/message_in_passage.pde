/**
 * MESSAGE IN PASSAGE
 * Haena Cho
 *  
 * Message in Passage is a Processing app that allows the sending and retrieving of messages 
 * while the messages visually decay over time (letters fade and images erode, embracing the passage of time).
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
PImage postbox, paperBefore, paperAfter, parcel;
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
final int READ_LETTER = 5;
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

boolean waitingForPhoto = false;

// decay
float decayRate = 0.01;

// retrieve
int retrieveTime = 0;
boolean alertOn = false;


void setup () {
    size (1920, 1080);

    systemFont = createFont ("Corethan-Bold.otf", 30);
    letterFont = createFont ("Corethan-Bold.otf", 20);
    textAlign (CENTER);

    postbox = loadImage ("postbox.png");
    paperBefore = loadImage ("paper-before.png");
    paperAfter = loadImage ("paper-after.png");
    parcel = loadImage ("package.png");
    imageMode (CENTER);

    h = new HandyRenderer (this);
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

        case READ_LETTER :
            drawReadLetter ();
            break;
        
        case VIEW_PHOTO :
            drawViewPhoto ();
            break;

    }

}

/***************
 MODE INTERFACES
 ***************/

void drawMain () {
    image (postbox, 960, 540, 600, 600);

    // draw parcels
    for (int i = 0; i < messages.size (); i++) {
        messages.get (i).decay ();
        image (parcel, 960, 720 - (30 * i), 180, 80);
    }

    drawButton ("send", BUTTON_LEFT);
    drawButton ("retrieve", BUTTON_RIGHT);
}

void drawSend () {
    image (postbox, 960, 900, 1400, 1400);

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
    h.rect (LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);

    // text area
    fill (0, 200);
    textFont (letterFont);
    textLeading (36);
    textAlign (LEFT);
    text (letterInput, LETTER_X, LETTER_Y, TEXT_WIDTH, TEXT_HEIGHT);

    drawButton ("cancel", BUTTON_LEFT);
    drawButton ("send", BUTTON_RIGHT);
}

void drawUploadPhoto () {
    drawTitle ("upload your picture: ");

    image (paperBefore, FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
    noFill ();
    rectMode (CENTER);
    h.setSeed (1234);
    h.rect (FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
    
    if (previewPhoto == null) {
        // h.setBackgroundColour (color (230, 220, 210));
        fill (180, 165, 140);
        h.rect (FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
    } else {
        image (previewPhoto.original, FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
        noFill ();
        h.rect (FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
    }
    

    drawButton ("select photo", FRAME_X, FRAME_Y - 30, 20);

    drawButton ("cancel", BUTTON_LEFT);
    drawButton ("send", BUTTON_RIGHT);
}

void drawRetrieve () {
    image (postbox, 960, 160, 1400, 1400);
    
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

        for (int i = 0; i < messages.size(); i++) {
            messages.get(i).decay();
            image(parcel, 960, 600 - (70 * i), 420, 200);
        }

        drawTitle ("retrieve what?", 880);
    }
}

void drawReadLetter () {
    if (choice instanceof Letter) {
        choice.display ();

        noFill ();
        rectMode (CENTER);
        h.setSeed (1234);
        h.rect (LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);
    } else if (choice instanceof Photo) {
        choice.display ();

        noFill ();
        rectMode (CENTER);
        h.setSeed (1234);
        h.rect (FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
        h.rect (FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
    }
    

    drawButton ("put back", BUTTON_LEFT);
    drawButton ("throw away", BUTTON_RIGHT);
}

void drawViewPhoto () {

}


/****************
 TITLES & BUTTONS
 ****************/

void drawTitle (String label, int y) {
    fill (0);
    textFont (systemFont);
    textAlign (CENTER);
    text (label, 960, y);
}

// overload
void drawTitle (String label) {
    fill (0);
    textFont (systemFont);
    textAlign (CENTER);
    text (label, 960, TITLE_Y);
}

void drawButton (String label, int x, int y, int fontSize) {
    fill (0);
    textFont (systemFont);
    textSize (fontSize);
    textAlign (CENTER);
    text (label, x, y);
}

// overload
void drawButton (String label, int x) {
    fill (0);
    textFont (systemFont);
    textAlign (CENTER);
    text (label, x, BUTTON_Y);
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

    Message () {
        timestamp = millis ();
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

        // all characters are fully visible
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
        for (int i = 0; i < decayCount; i++) {
            int index = int (random (content.length ()));
            characterOpacity [index] = max (0, characterOpacity [index] - decayRate);
        }

        // background letter fading
        letterOpacity = 500 * decayCount * decayRate;    
    }

    // override
    void display () {
        super.display ();

        // display letter background (layer for decay)
        tint (255, 255);
        image (paperBefore, LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);

        tint (255, letterOpacity);
        image (paperAfter, LETTER_X, LETTER_Y, LETTER_WIDTH, LETTER_HEIGHT);
        // reset tint
        tint (255, 255);

        // display text
        // set text position
        float x = LETTER_X - TEXT_WIDTH / 2;
        float y = LETTER_Y - TEXT_HEIGHT / 2;

        textFont (letterFont);
        textLeading (36);
        textAlign (LEFT);

        for (int i = 0; i < content.length (); i++) {
            char c = content.charAt (i);

            // line change
            if (c == '\n' || x > 1110) {
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
    float [] pixelSaturation;
    float frameOpacity = 255;

    Photo (String filename) {
        super ();
        original = loadImage (filename);
        original.loadPixels ();
        
        decayed = createImage (PHOTO_WIDTH, PHOTO_HEIGHT, HSB);

        // retrieve pixel saturation
        pixelSaturation = new float [original.pixels.length];
        for (int i = 0; i < pixelSaturation.length; i++) {
            pixelSaturation [i] = saturation (original.pixels [i]);
        }
    }

    // override
    void decay () {
        if (isOpened) {return;}

        // calculate time passage (in secs) 
        float age = millis () - timestamp;
        int decayCount = int (age / 1000);

        for (int i = 0; i < decayCount; i++) {
            int index = int (random (pixelSaturation.length));
            pixelSaturation [index] = max (0, pixelSaturation [index] - decayRate * 255);
        }

        // background frame fading
        frameOpacity = 500 * decayCount * decayRate;
    }

    void display () {
        super.display ();

        // display photo frame background (layer for decay)
        tint (255, 255);
        image (paperBefore, FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);

        tint (255, frameOpacity);
        image (paperAfter, FRAME_X, FRAME_Y, FRAME_WIDTH, FRAME_HEIGHT);
        // reset tint
        tint (255, 255);

        // display photo
        original.loadPixels ();
        decayed.loadPixels ();

        for (int i = 0; i < decayed.pixels.length; i++) {
            float h = hue (original.pixels [i]);
            float b = brightness (original.pixels [i]);

            decayed.pixels [i] = color (h, pixelSaturation [i], b);
        }

        decayed.updatePixels ();
        image (decayed, FRAME_X, FRAME_Y - 30, PHOTO_WIDTH, PHOTO_HEIGHT);
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
                mode = MAIN;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                messages.add (new Letter (letterInput));
                // reset letter
                letterInput = "";
                mode = MAIN;
            }
            break;

        case UPLOAD_PHOTO :
            if (buttonClicked (BUTTON_LEFT, BUTTON_Y)) {
                uploadedPhoto = null;
                mode = MAIN;
            } else if (buttonClicked (BUTTON_RIGHT, BUTTON_Y)) {
                // send photo
                if (uploadedPhoto != null) {
                    messages.add (new Photo (uploadedPhoto));
                    uploadedPhoto = null;
                    mode = MAIN;
                } else {
                    println ("no photo selected");
                }
            } else if (buttonClicked (FRAME_X, FRAME_Y - 30)) {
                // upload photo
                waitingForPhoto = true;
                selectInput ("select a photo to send: ", "fileSelected");
            }
            break;
        
        case RETRIEVE :
            for (int i = 0; i < messages.size (); i++) {
                if (dist (960, 600 - (70 * i), mouseX, mouseY) < 50) {
                    choice = messages.get (i);
                    choiceIndex = i;
                    mode = READ_LETTER;
                }
            }
            break;
        
        case READ_LETTER :
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