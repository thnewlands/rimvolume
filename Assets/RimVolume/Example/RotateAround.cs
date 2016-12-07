using UnityEngine;
using System.Collections;

public class RotateAround : MonoBehaviour {

    public float rotatespeed;

	void Update () {
        transform.Rotate(transform.up, rotatespeed);
        //transform.Rotate(transform.right, rotatespeed);
    }
}
