using UnityEngine;
using System.Collections;

public class Move : MonoBehaviour {

    public Vector3 dir;
	
	// Update is called once per frame
	void Update () {
        transform.position += dir;
	}
}
