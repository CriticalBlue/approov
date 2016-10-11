/*****************************************************************************
 * Project:     Demo
 * File:        RequestShape.java
 * Original:    Created on 1 June 2016 by matthewb
 * Copyright(c) 2002 - 2016 by CriticalBlue Ltd.
 ****************************************************************************/
package com.criticalblue.demo;

import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.util.Log;

import java.util.HashMap;
import java.util.Map;

import android.view.View;
import android.widget.TextView;

import com.android.volley.AuthFailureError;
import com.android.volley.Request;
import com.android.volley.RequestQueue;
import com.android.volley.Response;
import com.android.volley.VolleyError;
import com.android.volley.toolbox.StringRequest;
import com.android.volley.toolbox.Volley;
import com.criticalblue.attestationlibrary.ApproovAttestation;
import com.criticalblue.attestationlibrary.android.AndroidPlatformSpecifics;


public class RequestShape extends Activity {

    // For manually testing attestation
    ApproovAttestation mAttestation;
    AndroidPlatformSpecifics mPlatformSpecifics;

    // Listener for new token received events from Approov library
    TokenReceiver mTokenReceiver;

    // The last token received from Approov servers
    String mLastToken = "";

    // The view displayed by this activity. Shows simple text to feed information to user
    TextView mTextView;

    // Log tag for searching in logcat
    String TAG = "RequestShape";

    // Request queue for testing server
    RequestQueue mQueue;

    // Server url
    // By default this is the URL for an emulated device to reach the local host of its host machine
    String sURL ="http://10.0.2.2:5000"; //local host python test server

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        // The activity is being created.

        setContentView(R.layout.activity_main);

        mTextView = (TextView) findViewById(R.id.request_text);

        // For manually testing attestation
        mPlatformSpecifics = new AndroidPlatformSpecifics(getApplicationContext());
        mAttestation = new ApproovAttestation(mPlatformSpecifics);

        mTokenReceiver = new TokenReceiver();
        mAttestation.registerBroadcastReceiver(mTokenReceiver);

        // Instantiate the RequestQueue.
        mQueue = Volley.newRequestQueue(this);
    }

    /**
     * Function called by a button press in the activity. Will trigger an event providing an Approov
     * token that will be valid for at least 5 seconds.
     *
     * @param pView the view that triggered the request
     */
    public void requestToken(View pView){
        mAttestation.fetchApproovToken();
    }

    /**
     * Broadcast receiver for the event marking that an Approov token is available.
     */
    public final class TokenReceiver
            extends BroadcastReceiver {

        TokenReceiver() { /* EMPTY */ }

        /**
         * Triggered on the TOKEN_RESPONSE intent being received
         * @param aContext the Context in which the receiver is running
         * @param aIntent the intent received
         */
        @Override
        public void onReceive(Context aContext, Intent aIntent) {

            Log.w(TAG, "onReceive");

            ApproovAttestation.AttestationResult aResult = (ApproovAttestation.AttestationResult)aIntent.getSerializableExtra("Result");

            mLastToken = aIntent.getStringExtra("Token");

            if (aResult == ApproovAttestation.AttestationResult.SUCCESS){
                Log.w(TAG, "Received token: " + mLastToken);
                sendRequestDetails();

            } else if (aResult == ApproovAttestation.AttestationResult.FAILURE){
                Log.w(TAG, "Failed to obtain token: " + mLastToken);
            } else {
                Log.w(TAG, "Got unknown token request result");
            }

        }
    }

    /**
     * Send a get message to the local host server to test server token testing logic
     */
    private void sendRequestDetails(){



        // Request a string response from the provided URL.
        StringRequest stringRequest = new StringRequest(Request.Method.GET, sURL,
                new Response.Listener<String>() {
                    @Override
                    public void onResponse(String response) {
                        mTextView.setText("Fetching shape...");
                        Log.w(TAG, "Token verified by server");
                        Log.w(TAG, "Response: " + response);

                        // Send intent to change to logged in activity
                        Intent intent = new Intent(getBaseContext(), DisplayShape.class);
                        intent.putExtra("Shape", response);
                        startActivity(intent);
                    }
                }, new Response.ErrorListener() {
            @Override
            public void onErrorResponse(VolleyError error) {
                if (mLastToken.isEmpty()){
                    mTextView.setText("Request details incorrect. Please try again.");
                    Log.w(TAG, "Got empty token!");
                } else {
                    mTextView.setText("Unknown server error. Please try again.");
                    Log.w(TAG, "That didn't work!");
                    error.printStackTrace();
                }
            }
        }){
            @Override
            public Map<String, String> getHeaders() throws AuthFailureError {
                Map<String, String> params = new HashMap<String, String>();
                params.put("ApproovToken", mLastToken);
                return params;
            }
        };
        // Add the request to the RequestQueue.
        mQueue.add(stringRequest);

    }

}