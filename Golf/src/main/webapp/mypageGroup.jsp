<%@page import="com.model.MemberDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="com.model.GameDAO"%>
<%@page import="com.model.GroupDAO"%>
<%@page import="com.model.GameVO"%>
<%@page import="com.model.MemberVO"%>
<%@ page language="java" contentType="text/html; charset=EUC-KR"
    pageEncoding="EUC-KR"%>
<%@ include file= "head.html" %>
<head>
    <meta charset="utf-8">
    <!--  This file has been downloaded from bootdey.com @bootdey on twitter -->
    <!--  All snippets are MIT license http://bootdey.com/license -->
    <title>single advisor profile - Bootdey.com</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
	<script src="https://code.jquery.com/jquery-1.10.2.min.js"></script>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@4.5.0/dist/css/bootstrap.min.css" rel="stylesheet">
	<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.0/dist/js/bootstrap.bundle.min.js"></script>
  <script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=ae9179ab2df613f93734a86b287b83c5&libraries=services"></script>
  <link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.7.0/css/font-awesome.min.css" rel="stylesheet" />

</head>

<body>
	<% 
	int game_id = Integer.parseInt(request.getParameter("id")); 
	String type = request.getParameter("type");
	
	MemberDAO memberDAO = new MemberDAO();
	GroupDAO groupDAO = new GroupDAO();
	
	GameVO gamevo = memberDAO.getGroupDetail(type, game_id); 
    ArrayList<MemberVO> members = new ArrayList<MemberVO>();
    members = groupDAO.getGroupMemberVO(gamevo.getGame_id());
    
	%>
    
    <div class="container">
        <div class="row justify-content-center">
          <div class="col-12 col-sm-8 col-lg-6">
            <!-- Section Heading-->
            <div class="section_heading text-center wow fadeInUp" data-wow-delay="0.2s" style="visibility: visible; animation-delay: 0.2s; animation-name: fadeInUp;">
              <h3> <%= gamevo.getGame_name() %> </h3>
              <span class="small">
              	<%
	            if(gamevo.getGame_type().equals("field")) {
              		out.print("필드");	
              	} else {
              		out.print("스크린 골프");
              	}
    			%>
              </span>
            </div>
          </div>
        </div>
        <table class="table my-3">
          <caption>참가자 정보</caption>
		  <thead>
		    <tr>
		      <th>장소</th>
		      <th>주소</th>
		      <th>날짜</th>
		      <th>인원</th>
		    </tr>
		  </thead>
		  <tbody>
		    <tr>
		      <td nowrap><%= gamevo.getLocation_name() %></td>
		      <td nowrap><%= gamevo.getLocation_address() %></td>
		      <td nowrap><%= gamevo.getGame_date() %></td>
		      <td nowrap><%= groupDAO.getGroupMemberCnt(gamevo.getGame_id()) %>/<%= gamevo.getTotal_member() %>명</td>
		    </tr>
		  </tbody>
		</table>
        <div class="row">
          <!-- 그룹 멤버 정보 -->
          <% for(MemberVO vo : members) {%>
          <div class="col-12 col-sm-6 col-lg-3">
            <div class="single_advisor_profile wow fadeInUp" data-wow-delay="0.2s" style="visibility: visible; animation-delay: 0.2s; animation-name: fadeInUp;">
              <!-- Team Thumb-->
              <div class="advisor_thumb">
              	<a href="infoPage2.jsp?nickName=<%= vo.getNickname() %>" target="_blank" onclick="window.open(this.href, '_blank', 'width=1000, height=721'); return false;">
              	<img class="img-auto" src="assets/profile_pic/<%= vo.getProfilePic() %>" alt="assets/profile_pic/default.jpg">
              	</a>
              </div>
              <!-- Team Details-->
              <div class="single_advisor_details_info">
                <h6> <%= vo.getNickname() %> </h6>
                <p class="designation">
                	<% if(vo.getAddress() == null) { %>
                		<%= "설정안됨" %>
                	<% } else { %>
                		<%= vo.getAddress() %>
                	<% } %>
                	&amp;
                	<% if(vo.getAge() == null) { %>
                		<%= "설정안됨" %>
                	<% } else { %>
                		<%= vo.getAge()+"세" %>
                	<% } %>
                </p>
              </div>
            </div>
          </div>
          <% } %>
        </div>
      </div>

	  <hr>
	  <div class="text-center">
	    <h4>장소 정보</h4>
	  	<span class="small"><%= gamevo.getLocation_address() %></span>
	  </div>
      <div class="row justify-content-center">        
        <div id="map" style="width:700px;height:500px;"></div>
      </div>
      
      
      <script>
      // 마커를 클릭하면 장소명을 표출할 인포윈도우 입니다
      var infowindow = new kakao.maps.InfoWindow({zIndex:1});
      
      var mapContainer = document.getElementById('map'), // 지도를 표시할 div 
          mapOption = {
              center: new kakao.maps.LatLng(36.2, 127.9786567), // 지도의 중심좌표
              level: 12 // 지도의 확대 레벨
          };  
      
      // 주소-좌표 변환 객체를 생성합니다
      var geocoder = new kakao.maps.services.Geocoder();


      
      // 지도를 생성합니다    
      var map = new kakao.maps.Map(mapContainer, mapOption); 
      
      // 장소 검색 객체를 생성합니다
      var ps = new kakao.maps.services.Places(); 
      
      // 키워드로 장소를 검색합니다
      ps.keywordSearch(<%= "'"+gamevo.getLocation_name()+"'"%>, placesSearchCB); 
      
      // 현재 지도 중심좌표로 주소를 검색해서 지도 좌측 상단에 표시합니다
      searchAddrFromCoords(map.getCenter(), displayCenterInfo);


      // 키워드 검색 완료 시 호출되는 콜백함수 입니다
      function placesSearchCB (data, status, pagination) {
          if (status === kakao.maps.services.Status.OK) {
      
              // 검색된 장소 위치를 기준으로 지도 범위를 재설정하기위해
              // LatLngBounds 객체에 좌표를 추가합니다
              var bounds = new kakao.maps.LatLngBounds();
      
              for (var i=0; i<data.length; i++) {
                  displayMarker(data[i]);    
                  bounds.extend(new kakao.maps.LatLng(data[i].y, data[i].x));
              }       
      
              // 검색된 장소 위치를 기준으로 지도 범위를 재설정합니다
              map.setBounds(bounds);
              map.setLevel(6);
          }
          
      }

      
      // 지도에 마커를 표시하는 함수입니다
      function displayMarker(place) {
          
          // 마커를 생성하고 지도에 표시합니다
          var marker = new kakao.maps.Marker({
              map: map,
              position: new kakao.maps.LatLng(place.y, place.x) 
          });
      
          // 마커에 클릭이벤트를 등록합니다
          kakao.maps.event.addListener(marker, 'click', function() {
              // 마커를 클릭하면 장소명이 인포윈도우에 표출됩니다
              infowindow.setContent('<div style="padding:5px;font-size:12px;">' + place.place_name + '</div>');
              infowindow.open(map, marker);
          });
      }

      function searchAddrFromCoords(coords, callback) {
      // 좌표로 행정동 주소 정보를 요청합니다
      geocoder.coord2RegionCode(coords.getLng(), coords.getLat(), callback);         
      }

      function searchDetailAddrFromCoords(coords, callback) {
      // 좌표로 법정동 상세 주소 정보를 요청합니다
      geocoder.coord2Address(coords.getLng(), coords.getLat(), callback);
      }

      // 지도 좌측상단에 지도 중심좌표에 대한 주소정보를 표출하는 함수입니다
      function displayCenterInfo(result, status) {
          if (status === kakao.maps.services.Status.OK) {
            var infoDiv = document.getElementById('centerAddr');

          for(var i = 0; i < result.length; i++) {
            // 행정동의 region_type 값은 'H' 이므로
            if (result[i].region_type === 'H') {
                infoDiv.innerHTML = result[i].address_name;
                break;
            }
          }
          }    
      }



        </script>


<style type="text/css">

.single_advisor_profile {
    position: relative;
    margin-bottom: 50px;
    -webkit-transition-duration: 500ms;
    transition-duration: 500ms;
    z-index: 1;
    border-radius: 15px;
    -webkit-box-shadow: 0 0.25rem 1rem 0 rgba(47, 91, 234, 0.125);
    box-shadow: 0 0.25rem 1rem 0 rgba(47, 91, 234, 0.125);
}
.single_advisor_profile .advisor_thumb {
    position: relative;
    z-index: 1;
    border-radius: 15px 15px 0 0;
    margin: 0 auto;
    padding: 1px 1px 0 1px;
    background-color: #ffffff;
    overflow: hidden;
}
.single_advisor_profile .advisor_thumb::after {
    -webkit-transition-duration: 500ms;
    transition-duration: 500ms;
    position: absolute;
    width: 150%;
    height: 80px;
    bottom: -45px;
    left: -25%;
    content: "";
    background-color: #ffffff;
    -webkit-transform: rotate(-15deg);
    transform: rotate(-15deg);
}
@media only screen and (max-width: 575px) {
    .single_advisor_profile .advisor_thumb::after {
        height: 160px;
        bottom: -90px;
    }
}
.single_advisor_profile .advisor_thumb .social-info {
    position: absolute;
    z-index: 1;
    width: 100%;
    bottom: 0;
    right: 30px;
    text-align: right;
}
.single_advisor_profile .advisor_thumb .social-info a {
    font-size: 14px;
    color: #020710;
    padding: 0 5px;
}
.single_advisor_profile .advisor_thumb .social-info a:hover,
.single_advisor_profile .advisor_thumb .social-info a:focus {
    color: #3f43fd;
}
.single_advisor_profile .advisor_thumb .social-info a:last-child {
    padding-right: 0;
}
.single_advisor_profile .single_advisor_details_info {
    position: relative;
    z-index: 1;
    padding: 30px;
    text-align: right;
    -webkit-transition-duration: 500ms;
    transition-duration: 500ms;
    border-radius: 0 0 15px 15px;
    background-color: #ffffff;
}
.single_advisor_profile .single_advisor_details_info::after {
    -webkit-transition-duration: 500ms;
    transition-duration: 500ms;
    position: absolute;
    z-index: 1;
    width: 50px;
    height: 3px;
    background-color: #3f43fd;
    content: "";
    top: 12px;
    right: 30px;
}
.single_advisor_profile .single_advisor_details_info h6 {
    margin-bottom: 0.25rem;
    -webkit-transition-duration: 500ms;
    transition-duration: 500ms;
}
@media only screen and (min-width: 768px) and (max-width: 991px) {
    .single_advisor_profile .single_advisor_details_info h6 {
        font-size: 14px;
    }
}
.single_advisor_profile .single_advisor_details_info p {
    -webkit-transition-duration: 500ms;
    transition-duration: 500ms;
    margin-bottom: 0;
    font-size: 14px;
}
@media only screen and (min-width: 768px) and (max-width: 991px) {
    .single_advisor_profile .single_advisor_details_info p {
        font-size: 12px;
    }
}
.single_advisor_profile:hover .advisor_thumb::after,
.single_advisor_profile:focus .advisor_thumb::after {
    background-color: #070a57;
}
.single_advisor_profile:hover .advisor_thumb .social-info a,
.single_advisor_profile:focus .advisor_thumb .social-info a {
    color: #ffffff;
}
.single_advisor_profile:hover .advisor_thumb .social-info a:hover,
.single_advisor_profile:hover .advisor_thumb .social-info a:focus,
.single_advisor_profile:focus .advisor_thumb .social-info a:hover,
.single_advisor_profile:focus .advisor_thumb .social-info a:focus {
    color: #ffffff;
}
.single_advisor_profile:hover .single_advisor_details_info,
.single_advisor_profile:focus .single_advisor_details_info {
    background-color: #070a57;
}
.single_advisor_profile:hover .single_advisor_details_info::after,
.single_advisor_profile:focus .single_advisor_details_info::after {
    background-color: #ffffff;
}
.single_advisor_profile:hover .single_advisor_details_info h6,
.single_advisor_profile:focus .single_advisor_details_info h6 {
    color: #ffffff;
}
.single_advisor_profile:hover .single_advisor_details_info p,
.single_advisor_profile:focus .single_advisor_details_info p {
    color: #ffffff;
}

.img-auto {
	width: 300px;
	height: 500px;
	object-fit: cover;
	object-position: 50% 50%; 
}

</style>




</body>
</html>