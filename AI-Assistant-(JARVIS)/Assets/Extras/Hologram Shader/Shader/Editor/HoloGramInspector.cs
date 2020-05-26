/*
 * Hologram shaderGUI by Eduardo Yassin
 * V1
 */

using UnityEditor;
using UnityEngine;

public class HoloGramInspector : ShaderGUI {

    //Main Maps
    MaterialProperty diff;
    MaterialProperty normal;
    MaterialProperty HoloMask;

    //hologram color
    MaterialProperty tint;

    //Scanlines properties
    MaterialProperty SSSsize;
    MaterialProperty OSSsize;
    MaterialProperty BigScanSpeed;
    MaterialProperty BigScanFreq;

    //Glow fresnel properties
    MaterialProperty Bias;
    MaterialProperty Scale;
    MaterialProperty Power;

    //Displacement and noise
    MaterialProperty NoiseValue;
    MaterialProperty GlitchToggle;
    MaterialProperty ScanlineDeformToggle;
    MaterialProperty DisplacementeToggle;

    //Meta
    MaterialProperty ScanlinesToggle;
    bool showHelp;
    bool ScanlinesHelp;
    bool NoiseHelp;
    bool FresnelHelp;

    MaterialEditor m_MaterialEditor;

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties){

        //Style similar to Standard shader
        this.m_MaterialEditor = materialEditor;
        m_MaterialEditor.SetDefaultGUIWidths();
        m_MaterialEditor.UseDefaultMargins();
        EditorGUIUtility.labelWidth = 0f;

        //Load Properties

        diff = ShaderGUI.FindProperty("_Diffuse", properties);
        normal = ShaderGUI.FindProperty("_Normal", properties);
        HoloMask = ShaderGUI.FindProperty("_HoloMask", properties);
        tint = ShaderGUI.FindProperty("_Tint", properties);
        ScanlinesToggle = ShaderGUI.FindProperty("_UseScreenSpaceScanlines", properties);
        SSSsize = ShaderGUI.FindProperty("_SSSsize",properties);
        OSSsize = ShaderGUI.FindProperty("_OSSsize", properties);
        BigScanFreq = ShaderGUI.FindProperty("_BigScanFreq", properties);
        BigScanSpeed = ShaderGUI.FindProperty("_BigScanSpeed", properties);

        Bias = ShaderGUI.FindProperty("_Bias", properties);
        Scale = ShaderGUI.FindProperty("_Scale", properties);
        Power = ShaderGUI.FindProperty("_Power", properties);

        NoiseValue = ShaderGUI.FindProperty("_RandomNoiseLevel", properties);
        GlitchToggle = ShaderGUI.FindProperty("_ToggleGlitch", properties);
        ScanlineDeformToggle = ShaderGUI.FindProperty("_ToggleScanlineDeform", properties);
        DisplacementeToggle = ShaderGUI.FindProperty("_DisplacementSwitch", properties);



        //Draw Gui
        HeaderGUI();
        GUILayout.Label("Main Textures", EditorStyles.boldLabel);
        GUILayout.Label("Albedo : Diffuse (RGB) and alpha (A)");
        GUIContent diffuseLabel = new GUIContent("", "Diffuse (RGB) and alpha (A)");
        GUIContent tintlabel = new GUIContent("Tint", "Hologram color");

        //m_MaterialEditor.TexturePropertySingleLine(diffuseLabel, diff);
        m_MaterialEditor.ShaderProperty(diff, diffuseLabel);
        m_MaterialEditor.ShaderProperty(tint, tintlabel);

        GUILayout.Label("Normal");
        GUIContent normalLabel = new GUIContent("");
        m_MaterialEditor.ShaderProperty(normal, normalLabel);

        GUIContent ScanlinesLabel = new GUIContent("Scanlines texture");
        m_MaterialEditor.ShaderProperty(HoloMask, ScanlinesLabel);

        ScanlinesGUI();
        FresnelGUI();
        NoiseGUI();
    }

    void HeaderGUI()
    {
        EditorGUILayout.BeginHorizontal();
        showHelp = GUILayout.Toggle(showHelp, "Open help box", "Button");
        EditorStyles.centeredGreyMiniLabel.fontSize = 13;
        GUILayout.Label("Hologram Shader settings",EditorStyles.centeredGreyMiniLabel);
        EditorGUILayout.EndHorizontal();
        if (showHelp)
            EditorGUILayout.HelpBox("to get correct sorting on this shader the model must combined into a single mesh \n otherway geometry that clips will still be rendered ", MessageType.Warning);
    }

    void ScanlinesGUI()
    {
        EditorGUILayout.BeginHorizontal();
        ScanlinesHelp = GUILayout.Toggle(ScanlinesHelp, "?", "Button", GUILayout.Width(25f));
        GUILayout.Label("Scanlines", EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();

        if (ScanlinesHelp||showHelp)
            EditorGUILayout.HelpBox("This toggles either screen space or object space scanlines \nSS scanlines : these do not deform with the model and will always be displayed from top to bottom relative to the screen. \nOS scanlines : these work on the models UV space and can deform along the objects geometry.",MessageType.Warning);

        GUIContent ScanToggle = new GUIContent("Use screespace scanlines");
        m_MaterialEditor.ShaderProperty(ScanlinesToggle, ScanToggle);

        if (ScanlinesToggle.floatValue == 1)
            {
            GUIContent SSSLabel = new GUIContent("Screen Space Scanlines Size");
            m_MaterialEditor.ShaderProperty(SSSsize, SSSLabel);
        }
        else
            {
            GUIContent OSSLabel = new GUIContent("Object Space Scanlines Size");
            m_MaterialEditor.ShaderProperty(OSSsize, OSSLabel);
        }
        GUILayout.Label("\nBig scanline properties \n");

        GUIContent bigScanFreqLabel = new GUIContent("Big scanline frequency");
        m_MaterialEditor.ShaderProperty(BigScanFreq, bigScanFreqLabel);
        GUIContent bigScanSpeedLabel = new GUIContent("Big scanline speed");
        m_MaterialEditor.ShaderProperty(BigScanSpeed, bigScanSpeedLabel);


    }

    void FresnelGUI()
    {
        EditorGUILayout.BeginHorizontal();
        FresnelHelp = GUILayout.Toggle(FresnelHelp, "?", "Button", GUILayout.Width(25f));
        GUILayout.Label("Edge glow and fresnel", EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();

        if (FresnelHelp || showHelp)
            EditorGUILayout.HelpBox("Here you can control the the edge glow and overal transparency of the hologram", MessageType.Warning);

        GUIContent biasLabel = new GUIContent("Fresnel bias", "Defines the Bias variable of the Fresnel equation.");
        m_MaterialEditor.ShaderProperty(Bias, biasLabel);
        GUIContent scaleLabel = new GUIContent("Fresnel scale", "Defines the Scale variable of the Fresnel equation.");
        m_MaterialEditor.ShaderProperty(Scale, scaleLabel);
        GUIContent powerLabel = new GUIContent("Fresnel power", "Defines the Power variable of the Fresnel equation.");
        m_MaterialEditor.ShaderProperty(Power, powerLabel);
    }

    void NoiseGUI()
    {
        EditorGUILayout.BeginHorizontal();
        NoiseHelp = GUILayout.Toggle(NoiseHelp, "?", "Button", GUILayout.Width(25f));
        GUILayout.Label("Noise and displacement", EditorStyles.boldLabel);
        EditorGUILayout.EndHorizontal();

        if (NoiseHelp || showHelp)
            EditorGUILayout.HelpBox("Here you can control the amount of noise the hologram gives and also you can turn of the general displacement feature of the shader or turn off specific functions of the displacement.", MessageType.Warning);

        GUIContent displaceLabel = new GUIContent("Displacement toggle","Toggle between using displacement or not.");
        m_MaterialEditor.ShaderProperty(DisplacementeToggle,displaceLabel );

        if (DisplacementeToggle.floatValue==1)
        {
            GUIContent glitchlabel = new GUIContent("Glitch effect","Turning this on displaces random vertices to create a glitchy effect.");
            m_MaterialEditor.ShaderProperty(GlitchToggle, glitchlabel);
            if (GlitchToggle.floatValue == 1)
            {
                GUIContent noiseLabel = new GUIContent("Glitch strength", "Controls the size and strength of the glitch.");
                m_MaterialEditor.ShaderProperty(NoiseValue, noiseLabel);
            }
            GUIContent ScanLabel = new GUIContent("Scanline displacement", "Adds a displacement effect to the big hologram scanline.");
            m_MaterialEditor.ShaderProperty(ScanlineDeformToggle, ScanLabel);
        }
        
    }

}
