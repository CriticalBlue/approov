package com.criticalblue.demo;

import android.app.Application;

import com.criticalblue.attestationlibrary.ApproovAttestation;
import com.criticalblue.attestationlibrary.android.AndroidPlatformSpecifics;

/**
 * Created by matthewb on 11/10/16.
 */
public class Shapes extends Application {

    // Approov SDK Objects
    ApproovAttestation mAttestation;
    AndroidPlatformSpecifics mPlatformSpecifics;

    @Override
    public void onCreate(){
        super.onCreate();
        mPlatformSpecifics = new AndroidPlatformSpecifics(getApplicationContext());
        mAttestation = new ApproovAttestation(mPlatformSpecifics);

    }

    public ApproovAttestation getApproovAttestation(){
        return mAttestation;
    }

    public AndroidPlatformSpecifics getAndroidPlatformSpecifics(){
        return mPlatformSpecifics;
    }

}
