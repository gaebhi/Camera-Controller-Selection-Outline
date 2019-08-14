# [Camera Controller / Selection Outline]

## 1.설명
* Camera Controller
  - 마우스 왼쪽 클릭 or 한손 터치 : 상하좌우 움직임
  - 마우스 오른쪽 클릭 or 양손 가깝게 터치 : 상하좌우 회전
  - 마우스 휠 or pinch : 줌인/줌아웃
  - 오브젝트 터치 : 
  - 줌인/줌아웃에 따른 안개 효과 (포스트 프로세싱)
  
* Selection Outline Shader
  - Normal 값 이용해서 아웃라인 그리는 쉐이더
    (각진 부분에 아웃라인이 끊기는 현상 발생)
  - Tangent 값 이용해서 아웃라인 그리는 쉐이더
    (각진 오브젝트의 노말 평균을 구해 탄젠트 값에 넣어줌 / 탄젠트 값에 넣는 이유 : 노말값에 덮어쓸 경우 빛의 방향과 노말값의 내적으로 빛을 계산하기 때문에 각진 부분이 어두워지는 현상 발생)
    
* Client : Unity 2017+

## 2. 이미지
* Camera Contrller (focus 예시)
![scene2](https://blogfiles.pstatic.net/MjAxOTA4MTRfMTcz/MDAxNTY1NzYzMzYyOTA1.Xe0F0iEyCarF7U4Ix6uuZHkrs79MFwOSJg5g6o1gHaIg.W7UH7bxJLuP23fLnhcmb0TZiaaZ7uirSQdS8JBW0RNAg.PNG.gaebhi/camera.png?type=w1 "S2")
  
* 적용 예시 - 왼쪽 normal값 이용한 쉐이더, 오른쪽 tangent값 이용한 쉐이더
![scene1](https://blogfiles.pstatic.net/MjAxOTA4MTJfMjUy/MDAxNTY1NTk0NDc0MDIw.970cxN4zPCA2f5PbHrE2MPPmPx0oJ_muZhNyfRDY-vQg.8oxQ1djIHYKxaixAYiInytBLZp5AWoLZV5C8cgo_XFAg.PNG.gaebhi/outline.png?type=w1 "S")
 
* 사용 예시
![sample](https://blogfiles.pstatic.net/MjAxOTA4MTJfMTIy/MDAxNTY1NTk0NDczNjk5.Dfo0WwJlpE1zpKVZtSZPh3YuGiZSaZ2coM5YRyEu6pwg.6IfA7OgQ2c4su13hSmGdc_00bOpb3llbsdzh2RhsARog.PNG.gaebhi/how_to_make_smooth_normal.png?type=w1 "sample")

  Editor에서 smoothed normal을 만들 오브젝트를 선택하고 
  menu의 Tools/Build Smoothed Normal을 눌러주면 Asssets/SmoothNormalMesh/ 폴더에 mesh가 생성된다.  
  mesh filter에 넣어주면 위 적용 예시와 같이 각진 부분의 아웃라인이 정상적으로 생성된다.
  
 ## 3. 링크
* [Video link](https://youtu.be/KtoyjWtBgx4 "link")
