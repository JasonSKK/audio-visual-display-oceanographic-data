#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    ofBackground(22);

    //Cursor
    ofHideCursor();

    //oscSetup
    osc.setup(PORT);
    osc1 = 0.0;

}

//--------------------------------------------------------------
void ofApp::update(){

    //OSC
    while(osc.hasWaitingMessages()) {
        ofxOscMessage m;
        osc.getNextMessage(&m);

        //Temperature
        if(m.getAddress() == "/waves/temp") {
            osc1 = m.getArgAsFloat(0);
            counter++;
        }

        //Significant_height
        if(m.getAddress() == "/waves/sign_height") {
            osc2 = m.getArgAsFloat(0);
            counter++;
        }

        //Zero_upcrossing
        if(m.getAddress() == "/waves/zero_upcrossing") {
            osc3 = m.getArgAsFloat(0);
            counter++;
        }

        //Max height
        if(m.getAddress() == "/waves/max_height") {
            osc4 = m.getArgAsFloat(0);
            counter++;
        }

    }

}

//--------------------------------------------------------------
void ofApp::draw(){

  //Temperature
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Temperature", 900, 50);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc1, 1, 1000, 18.96, 26.71), 1000, 50);

    //Significant_Height
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Significant_Height", 1150, 50);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc2, 1, 1000, 0.020, 0.880), 1300, 50);

    //Zero_Upcrossing_Wave_Period
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Z_crossing_w_period", 900, 75);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc3, 1, 1000, 3.2, 8.7), 1075, 75);

    //Max_Height
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Max_height", 1150, 75);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc4, 1, 1000, 0.025, 1.300), 1300, 75);


    //Colours____Significant_Height && Zero_upcrossing_period
    for(int i = 0; i <= counter; i++){
        //RED
        //Significant_height Colour parameter
        if(sign_height < osc2){
            sign_height = sign_height + 0.0125;
            red = sign_height;
            red = ofMap(red, 1, 1000, 55, 255);
            sleep(0.1);
        };
        if(sign_height > osc2){
            sign_height = sign_height - 0.0125;
            red = ofMap(sign_height, 1, 1000, 55, 255);
            //red = ofMap(red, 1, 1000, 1, 15); //only if pow(red, 2)
            sleep(0.1);
        };


        //GREEN
        //Significant_height Colour parameter
        if(z_upcrossing < osc3){
            z_upcrossing = z_upcrossing + 0.0125;
            green = ofMap(z_upcrossing, 1, 1000, 20, 255);
            sleep(0.1);
        };
        if(z_upcrossing > osc3){
            z_upcrossing = z_upcrossing - 0.0125;
            green = ofMap(z_upcrossing, 1, 1000, 20, 255);
            sleep(0.1);
        };
    }


    /*  //GREEN
    //Significant_height Colour parameter
    if(max < osc4){
        max = max + 0.0125;
        max = ofMap(max, 1, 1000, 20, 255);
        sleep(0.1);
    };
    if(z_upcrossing > osc3){
        z_upcrossing = z_upcrossing - 0.0125;
        green = ofMap(z_upcrossing, 1, 1000, 20, 255);
        sleep(0.1);
    };
    */











    //ofNoFill();
    ofSetColor(ofMap(osc1, 1, 1000, 55, 255), 0, 0);
    ofSetCircleResolution(100);
    ofCircle(ofMap(red, 55, 255, 200, ofGetWidth()), //sig_height
        ofMap(green, 20, 255, 50, ofGetHeight()), //z_upcrossing
             ofMap(osc4, 1, 1000, 20, 200)); //max

}

//--------------------------------------------------------------
void ofApp::keyPressed(int key){

}

//--------------------------------------------------------------
void ofApp::keyReleased(int key){

}

//--------------------------------------------------------------
void ofApp::mouseMoved(int x, int y ){

}

//--------------------------------------------------------------
void ofApp::mouseDragged(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mousePressed(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseReleased(int x, int y, int button){

}

//--------------------------------------------------------------
void ofApp::mouseEntered(int x, int y){

}

//--------------------------------------------------------------
void ofApp::mouseExited(int x, int y){

}

//--------------------------------------------------------------
void ofApp::windowResized(int w, int h){

}

//--------------------------------------------------------------
void ofApp::gotMessage(ofMessage msg){

}

//--------------------------------------------------------------
void ofApp::dragEvent(ofDragInfo dragInfo){

}
