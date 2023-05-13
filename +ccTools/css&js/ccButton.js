	function setup(htmlComponent) {
		const btn = document.querySelector("button");
		const evt = ["", "ButtonEnabled", "ButtonDisabled"];
		btn.addEventListener("click", function(event) {
			if (evt.includes(htmlComponent.Data)) {
				htmlComponent.Data = "ButtonPushed";
			};
		});
		htmlComponent.addEventListener("DataChanged", function(event) {
			switch (event.Data) {
				case "ButtonEnabled":
					btn.disabled = false;
					break;
				case "ButtonDisabled":
					btn.disabled = true;
					break;
			};
		});
	}