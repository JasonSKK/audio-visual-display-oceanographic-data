#pragma once

#include "ofMain.h"
#include "ofxBox2d.h"
#include "ofxBox2dParticleSystem.h"
#include "ofxOsc.h"

#define PORT 12345

using namespace ofxBox2dParticleSystem;

class ofApp : public ofBaseApp {

	public:

    void setup();
    void update();
    void draw();

    void keyPressed(int key);
    void keyReleased(int key);
    void mouseMoved(int x, int y );
    void mouseDragged(int x, int y, int button);
    void mousePressed(int x, int y, int button);
    void mouseReleased(int x, int y, int button);
    void mouseEntered(int x, int y);
    void mouseExited(int x, int y);
    void windowResized(int w, int h);
    void dragEvent(ofDragInfo dragInfo);
    void gotMessage(ofMessage msg);

    void drawGravity(ofPoint p, ofPoint gravity);

    //EasyCam
    ofEasyCam cam;


    //bacground_colour_var
    int bco = 22;

    //ofBox2d
    ofxBox2d box2d;
    ParticleSystem particleSystem;
    vector <shared_ptr<ofxBox2dRect>> rects;

    //OSC
    ofxOscReceiver osc;

    float osc1 = 0.0;//temp
    float osc2 = 0.0;//sign_height
    float osc3 = 0.0;//zero_upcrossing
    float osc4 = 0.0;//max_height

    float noisea = 0.0;//noise attack

    int counter = 0;
    float step = 0.01;
    //OSC

    //OSC control variables
    float temp = 0;
    float sign_height = 1;
    float z_upcrossing = 1;
    float max = 1;


    //RGB
    float red = 1;
    float green = 1;


    float test = 0.0;


};
