private var anim : Animation;

private var loop  : String[]=["idle@loop", "walk@loop", "run@loop"];
private var damage : String[]=["damage","die"];
private var attack   : String[]=["attack_sword_01", "attack_sword_02","attack_sword_03"];
private var etc  : String[]=["tumbling", "jump", "sit", "sit_idle@loop", "stand"];

function Start () {
	anim=GetComponent (Animation);

	anim["idle@loop"].speed=1.0;
}

function OnGUI () {

	CategoryView ("loop", loop, 10);
	CategoryView ("damage", damage, 170);
	CategoryView ("attack", attack, 330);
	CategoryView ("etc", etc, 490);
}

function CategoryView (nme:String, cat:String[], x:int) {
	GUI.Box (Rect(x,10,150,23), nme);
	for (var i:int=0; i<cat.Length; i++) {
		if (GUI.Button (Rect(x, 35+(25*i), 150, 23), cat[i]) ) {
			
			GoAnim (cat[i]);
		}
	}

}

function GoAnim (nme:String) {

	anim.CrossFade (nme);

	while (anim.IsPlaying) {
		yield;
	}

	anim.CrossFade ("idle@loop");
}