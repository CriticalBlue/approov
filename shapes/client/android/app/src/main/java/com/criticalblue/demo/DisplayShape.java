/*****************************************************************************
 * Project:     ApproovClientDemo
 * File:        DisplayShape.java
 * Original:    Created on 14 Sep 2016
 * Copyright(c) 2002 - 2016 by CriticalBlue Ltd.
 ****************************************************************************/

package com.criticalblue.demo;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

public class DisplayShape extends Activity {

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_display);

        Bundle aExtras = getIntent().getExtras();

        TextView aTextView = (TextView)findViewById(R.id.home_text);
        aTextView.setText(aExtras.getString("Shape"));

    }

    /**
     * Called by a button click in the view. Will return to first activity.
     *
     * @param pView the view that triggered the request
     */
    public void reset(View pView){
        // Send intent to return to request a new shape
        Intent intent = new Intent(getBaseContext(), RequestShape.class);
        startActivity(intent);
        finish();
    }

}
