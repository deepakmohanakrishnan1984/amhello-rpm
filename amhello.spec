Name: amhello
Version: 1.0
Release: 4%{?dist}
Summary: Sample project
URL: https://github.com/comcast-jonm/amhello
License: GPLv2+
Group: Applications/Internet
Source0: amhello-1.0.tar.gz

%description
Sample project

%prep
#cp /vagrant/amhello-1.0.tar.gz $HOME/rpmbuild/SOURCES
%setup -q

%build
%configure
make

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(444, root, root, 755)
%{_bindir}/hello
%doc %{_docdir}/amhello/README


%changelog
