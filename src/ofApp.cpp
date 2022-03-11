#include "ofApp.h"

//--------------------------------------------------------------
void ofApp::setup(){

    ofBackground(22);
    ofSetVerticalSync(true);

    // Cursor
    ofHideCursor();

    // oscSetup
    osc.setup(PORT);
    osc1 = 0.0;

    // box2d Setup
    box2d.init();
    box2d.setFPS(120);
    box2d.createBounds();
    box2d.setGravity(0, 100);
    box2d.registerGrabbing();

    int maxParticles = 30000; // 30k particles

    particleSystem.init(box2d.getWorld());
    particleSystem.setMaxParticles(maxParticles);
    particleSystem.setRadius(2.1);

    glm::vec2 center(ofGetWidth()/2, ofGetHeight()/2);

    for(int i=0; i<maxParticles; i++) {
        particleSystem.addParticle(center.x + ofRandom(-ofGetWidth(), ofGetWidth()),
                                   center.y + ofRandom(-100, 100));
    }


}

//--------------------------------------------------------------
void ofApp::update(){
    box2d.update();

    // OSC
    while(osc.hasWaitingMessages()) {
        ofxOscMessage m;
        osc.getNextMessage(&m);

        // Temperature
        if(m.getAddress() == "/waves/temp") {
            osc1 = m.getArgAsFloat(0);
            counter++;
        }

        // Significant_height
        if(m.getAddress() == "/waves/sign_height") {
            osc2 = m.getArgAsFloat(0);
            counter++;
        }

        // Zero_crossing
        if(m.getAddress() == "/waves/zero_upcrossing") {
            osc3 = m.getArgAsFloat(0);
            counter++;
        }

        // Max height
        if(m.getAddress() == "/waves/max_height") {
            osc4 = m.getArgAsFloat(0);
            counter++;
        }

        // Noisea
        if(m.getAddress() == "/waves/noisea") {
            noisea = m.getArgAsFloat(0);
            counter++;
        }

    }

    // Noise-attack
    if( noisea == 0){
        bco = 22;
        ofSetBackgroundColor(bco);
    }
    if( noisea == 1){
        bco = ofMap(sin(ofGetFrameNum() * 10), -1, 1, 0, 255);
        ofSetBackgroundColor(bco);
        }
    if( noisea == 2){
        bco = ofMap(sin(ofGetFrameNum() * 10), -1, 1, 0, 255);
        ofSetBackgroundColor(bco);
        }

}
//--------------------------------------------------------------
void ofApp::drawGravity(ofPoint p, ofPoint gravity) {

}

//--------------------------------------------------------------
void ofApp::draw(){

    // Temperature
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Temperature", 900, 50);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc1, 1, 1000, 18.96, 26.71), 1000, 50);

    // Significant_Height
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Significant_Height", 1150, 50);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc2, 1, 1000, 0.020, 0.880), 1300, 50);

    // Zero_Upcrossing_Wave_Period
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Z_crossing_w_period", 900, 75);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc3, 1, 1000, 3.2, 8.7), 1075, 75);

    // Max_Height
    ofSetColor(255, 100, 0);
    ofDrawBitmapString("Max_height", 1150, 75);
    ofSetColor(255, 0, 0);
    ofDrawBitmapString(ofMap(osc4, 1, 1000, 0.025, 1.300), 1300, 75);

    particleSystem.updateMesh();

    // Colours: Significant_Height + Zero_crossing_period
    for(int i = 0; i <= counter; i++){
        // RED
        // Significant_height Colour parameter
        if(sign_height < osc2){
            sign_height = sign_height + 0.0125;
            red = sign_height;
            red = ofMap(red, 1, 1000, 55, 255);
            sleep(0.1);
        };
        if(sign_height > osc2){
            sign_height = sign_height - 0.0125;
            red = ofMap(sign_height, 1, 1000, 55, 255);
            // red = ofMap(red, 1, 1000, 1, 15); //only if pow(red, 2)
            sleep(0.1);
        };


        // GREEN
        // Significant_height Colour parameter
        if(z_upcrossing < osc3){
            z_upcrossing = z_upcrossing + 0.0125;
            green = ofMap(z_upcrossing, 1, 1000, 20, 100);
            sleep(0.1);
        };
        if(z_upcrossing > osc3){
            z_upcrossing = z_upcrossing - 0.0125;
            green = ofMap(z_upcrossing, 1, 1000, 20, 100);
            sleep(0.1);
        };
    }

    ofSetColor(green, 0, red * 2);
    particleSystem.draw();

    // particle relations
    // Copyright (c) 2006-2010 Erin Catto http://www.gphysics.com
    // ofxBox2d - example-ParticleSystem
    ofNoFill();
    auto * contacts = particleSystem.getParticleSystem()->GetContacts();
    auto * positions = particleSystem.getParticleSystem()->GetPositionBuffer();
    int count = particleSystem.getParticleSystem()->GetContactCount();
    for(int i=0; i<count; i++) {
        auto contact = contacts[i];
        auto a = ofxBox2d::toOf(positions[contact.GetIndexA()]);
        auto b = ofxBox2d::toOf(positions[contact.GetIndexB()]);
        ofSetColor(red, green, 0);//, 10, 255);// , temp * sin(temp * i * 0.01), 0 );
        ofDrawLine(a, b);
        //        ofDrawLine(a, a+100);
    }


    for(int i = 0; i <= counter; i++){

        // Max_height amount parameter
        max = ofMap(osc4, 1, 1000, 1.0, 1.5);

        // Up & down gravity if temp (osc1) (1, 1000).isEven
        if((int)osc1 % 2 == 0){temp = -50;}
        else
        {temp = 50;}
        box2d.setGravity(temp * max, 70);
    }


    box2d.setGravity(temp * max, 70);



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
    ofNoFill();
    particleSystem.addParticle(x, y);

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
